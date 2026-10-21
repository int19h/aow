{ P2 recovery in original code order. }
type
  TP2HeroLevel = record
    Experience, Reserved: Integer;
  end;
const
  P2HeroLevels: array[0..5] of TP2HeroLevel = (
    (Experience: 15; Reserved: 1), (Experience: 15; Reserved: 1),
    (Experience: 20; Reserved: 1), (Experience: 20; Reserved: 1),
    (Experience: 25; Reserved: 1), (Experience: 25; Reserved: 29));
var
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

{ needs: draft P1 TRace.GetRelation(Race: Shortint): TStatus,
  call 5577F02E takes DL and returns AL. }
function P2RaceRelation(Race: TRace; OtherRace: Shortint): TStatus; assembler;
asm JMP TRace.GetRelation end;

{ needs: draft P1 dAlignmentToStatus(A, B: TAlignment): TStatus;
  call 5577F04B uses AL/DL and returns AL. }
function P2AlignmentRelation(A, B: TAlignment): TStatus; assembler;
asm JMP dAlignmentToStatus end;

{ needs: draft P1 MoraleValueToMorale(Value: Integer): TMorale;
  5577F178 sign extends the morale byte into EAX before the call. }
function P2MoraleValueToMorale(Value: Integer): TMorale; assembler;
asm JMP MoraleValueToMorale end;

type
  { Local views of unmarked foreign fields; no foreign layout is changed. }
  TP2NodeFields = class(TObject)
    Owner: Pointer;
    Children: TList;
  end;
  TP2AbilityControlFields = class(TObject)
    Reserved: array[4..23] of Byte;
    CombatAbilities: TAbilityTypeList;
    Enchantments: TAbilityTypeList;
  end;

{ needs: draft P1 TAbilityTypeList.GetAbility(Index: Integer): TAbility;
  5577F1AB returns a pointer whose +0C ability ID is read at 5577F1B0. }
function P2TypeAbility(List: TAbilityTypeList; Index: Integer): TAbility; assembler;
asm JMP TAbilityTypeList.GetAbility end;

{ needs: draft P1 TAbilityControl.GetAbility(ID: Integer): TAbility;
  5577F3C3 returns the class-tested pointer. }
function P2ControlAbility(Control: TAbilityControl; ID: Integer): TAbility; assembler;
asm JMP TAbilityControl.GetAbility end;

{ needs: draft P1 TAbilityOwner.GetAbilityData(ID: Integer): TAbilityData;
  calls 5577F2EB/5577F3F1 return a pointer with enchantment at +10. }
function P2AbilityData(AOwner: TAbilityOwner; ID: Integer): TAbilityData; assembler;
asm JMP TAbilityOwner.GetAbilityData end;

type
  { Local VMT view while foreign draft result types remain undeclared.
    Offsets proved by calls 5577F57C, 5577F599, 5577F5D1, 5577F60C, 5577F651. }
  { Damage-value record, five dwords at 5577F9FF..5577FA24. }
  TP2DamageValue = record
    Damage, Reserved, Cost, Reserved2, Reserved3: Integer;
  end;
  TP2AbilityCalls = class(TObject)
    ReservedFields: array[4..11] of Byte;
    AbilityID: Integer;
    procedure Slot00; virtual; abstract;
    procedure Slot04; virtual; abstract;
    procedure Slot08; virtual; abstract;
    procedure Slot0C; virtual; abstract;
    procedure Slot10; virtual; abstract;
    procedure Slot14; virtual; abstract;
    procedure Slot18; virtual; abstract;
    procedure Slot1C; virtual; abstract;
    procedure Slot20; virtual; abstract;
    procedure Slot24; virtual; abstract;
    procedure Slot28; virtual; abstract;
    procedure Slot2C; virtual; abstract;
    procedure Slot30; virtual; abstract;
    procedure Slot34; virtual; abstract;
    procedure Slot38; virtual; abstract;
    procedure Slot3C; virtual; abstract;
    procedure Slot40; virtual; abstract;
    procedure Slot44; virtual; abstract;
    procedure Slot48; virtual; abstract;
    function GetAbSet(Index: Integer): Boolean; virtual; abstract;
    procedure Slot50; virtual; abstract;
    function AbilityType: TAbilityType; virtual; abstract;
    function AbilityName(AOwner: TAbilityOwner): string; virtual; abstract;
    procedure Slot5C; virtual; abstract;
    procedure Slot60; virtual; abstract;
    procedure Slot64; virtual; abstract;
    procedure Slot68; virtual; abstract;
    procedure Slot6C; virtual; abstract;
    function AbilityLevel(AOwner: TAbilityOwner): Integer; virtual; abstract;
    function AbilityEnabled(AOwner: TAbilityOwner): Boolean; virtual; abstract;
    procedure Slot78; virtual; abstract;
    procedure Slot7C; virtual; abstract;
    procedure Slot80; virtual; abstract;
    procedure Slot84; virtual; abstract;
    procedure Slot88; virtual; abstract;
    function SourceName(AOwner: TAbilityOwner): string; virtual; abstract;
    function AbilityInherent(AOwner: TAbilityOwner): Boolean; virtual; abstract;
    function AbilityInherentLevel(AOwner: TAbilityOwner): Shortint; virtual; abstract;
    procedure Slot98; virtual; abstract;
    procedure Slot9C; virtual; abstract;
    procedure SlotA0; virtual; abstract;
    function CanAddUnit(AUnit: TAbstractUnit): Boolean; virtual; abstract;
    procedure SlotA8; virtual; abstract;
    function AddUnit(AUnit: TAbstractUnit): Boolean; virtual; abstract;
    procedure SlotB0; virtual; abstract;
    procedure SlotB4; virtual; abstract;
    procedure SlotB8; virtual; abstract;
    procedure SlotBC; virtual; abstract;
    procedure SlotC0; virtual; abstract;
    procedure SlotC4; virtual; abstract;
    procedure SlotC8; virtual; abstract;
    procedure SlotCC; virtual; abstract;
    class function GroupBehavior: TGroupBehavior; virtual; abstract;
    procedure SlotD4; virtual; abstract;
    procedure SlotD8; virtual; abstract;
    procedure DamageValueEx(AOwner: TAbilityOwner; Target: TAbstractUnit;
      Mode: Byte; var Info: TP2DamageValue); virtual; abstract;
    procedure OffensiveStrength(AOwner: TAbilityOwner; var Strength: Integer;
      var DamageTypes: TDamageTypes); virtual; abstract;
  end;
  TP2PString = ^string;

function P2AlignmentToIR(Alignment: TAlignment): Shortint; assembler;
asm JMP AlignmentToIR end;

procedure P2TranslateRStr(const Text: string; var Dest: string); assembler;
asm JMP TranslateRStr end;

resourcestring
  P2InherentRStr = 'Inherent'; { original resource at 5570716C }



function P2VMTAbility(List: TAbilityTypeList; Index: Integer): TP2AbilityCalls; assembler;
asm JMP TAbilityTypeList.GetAbility end;

const
  { needs: original shared ability-type text table at 558E8250.
    These defaults follow the recovered ability-type enumeration. }
  P2AbilityTypeNames: array[TAbilityType] of string =
    ('Enhancement', 'Handicap', 'Movement', 'Combat', 'Enchantment');

{ needs: draft P5 TAIGroupList.FindID(ID: Integer): TAIGroup;
  5577FBD9..5577FBE6 passes saved group ID in EDX and uses returned object. }
function P2FindGroup(List: TAIGroupList; ID: Integer): TAIGroup; assembler;
asm JMP TAIGroupList.FindID end;

function P2AbImmunity(AOwner: TAbilityOwner): TDamageTypes; assembler;
asm JMP TAbilityOwner.GetAbImmunityTypesAll end;
function P2AbProtection(AOwner: TAbilityOwner): TDamageTypes; assembler;
asm JMP TAbilityOwner.GetAbProtectionTypesAll end;

function P2MoveTypesToInt(MoveTypes: TMoveTypes): Integer; assembler;
asm JMP MoveTypesToInt end;

{ needs: draft P1 return types; call sites 5578011B/5578012A/55780149. }
function P2DiplomaticRelation(Relations: TPlayerDiplomaticRelations; Player: Integer): TDiplomaticRelation; assembler;
asm JMP TPlayerDiplomaticRelations.GetDiplomaticRelation end;
function P2Explored(MapField: TAoWMapField; Player: Integer): Boolean; assembler;
asm JMP TAoWMapField.GetExplored end;
function P2VisibleForPlayer(Map: TAoWHSMap; X,Y,L,Player: Integer): Boolean; assembler;
asm POP EBP; JMP TAoWHSMap.VisibleForPlayer end;

function P2ConcealmentActive(Field: TAoWMapField): Boolean; assembler;
asm JMP TAoWMapField.GetConcealmentActive end;
function P2Spell(Control: TSpellControl; ID: Integer): TSpell; assembler;
asm JMP TSpellControl.GetSpell end;

type
  { VMT +94 is ExpandAbility for an owner; +54/+58 are enchantment setters. }
  TP2OwnerCalls = class(TObject)
    procedure Slot00; virtual; abstract;
    procedure Slot04; virtual; abstract;
    procedure Slot08; virtual; abstract;
    procedure Slot0C; virtual; abstract;
    procedure Slot10; virtual; abstract;
    procedure Slot14; virtual; abstract;
    procedure Slot18; virtual; abstract;
    procedure Slot1C; virtual; abstract;
    procedure Slot20; virtual; abstract;
    procedure Slot24; virtual; abstract;
    procedure Slot28; virtual; abstract;
    procedure Slot2C; virtual; abstract;
    procedure Slot30; virtual; abstract;
    procedure Slot34; virtual; abstract;
    procedure Slot38; virtual; abstract;
    procedure Slot3C; virtual; abstract;
    procedure Slot40; virtual; abstract;
    procedure Slot44; virtual; abstract;
    procedure Slot48; virtual; abstract;
    procedure Slot4C; virtual; abstract;
    procedure Slot50; virtual; abstract;
    procedure Slot54; virtual; abstract;
    procedure Slot58; virtual; abstract;
    procedure Slot5C; virtual; abstract;
    procedure Slot60; virtual; abstract;
    procedure Slot64; virtual; abstract;
    procedure Slot68; virtual; abstract;
    procedure Slot6C; virtual; abstract;
    procedure Slot70; virtual; abstract;
    procedure Slot74; virtual; abstract;
    procedure Slot78; virtual; abstract;
    procedure Slot7C; virtual; abstract;
    procedure Slot80; virtual; abstract;
    procedure Slot84; virtual; abstract;
    procedure Slot88; virtual; abstract;
    procedure Slot8C; virtual; abstract;
    procedure Slot90; virtual; abstract;
    function Expand(ID: Integer): Boolean; virtual; abstract;
  end;
  TP2EnchantmentCalls = class(TObject)
    Reserved: array[4..19] of Byte;
    Duration: Byte;
    procedure Slot00; virtual; abstract;
    procedure Slot04; virtual; abstract;
    procedure Slot08; virtual; abstract;
    procedure Slot0C; virtual; abstract;
    procedure Slot10; virtual; abstract;
    procedure Slot14; virtual; abstract;
    procedure Slot18; virtual; abstract;
    procedure Slot1C; virtual; abstract;
    procedure Slot20; virtual; abstract;
    procedure Slot24; virtual; abstract;
    procedure Slot28; virtual; abstract;
    procedure Slot2C; virtual; abstract;
    procedure Slot30; virtual; abstract;
    procedure Slot34; virtual; abstract;
    procedure Slot38; virtual; abstract;
    procedure Slot3C; virtual; abstract;
    procedure Slot40; virtual; abstract;
    procedure Slot44; virtual; abstract;
    procedure Slot48; virtual; abstract;
    procedure Slot4C; virtual; abstract;
    procedure Slot50; virtual; abstract;
    procedure SetUpkeep(Value: Integer); virtual; abstract;
    procedure SetSource(Player: Shortint); virtual; abstract;
  end;
  TP2SpellFields = class(TObject)
    Reserved: array[4..59] of Byte;
    Duration: Byte;
  end;
const
  P2StormDamageType: array[TStormType] of TDamageType =
    (dtNone,dtFire,dtDeath,dtHoly,dtCold,dtLightning,dtPoison);

function P2HitRole(Value: Integer): Boolean; assembler;
asm JMP HitRole end;
procedure P2UnitChanged(Map: TAoWHSMap; AUnit: TAbstractUnit); assembler;
asm JMP TAoWHSMap.UnitChanged end;

function P2FieldPlayer(Field: TAoWMapField): Shortint; assembler;
asm JMP TAoWMapField.GetPlayer end;

function P2HitPercent(HitPoints, Hits: Shortint): Byte; assembler;
asm JMP HitPointsToHitPcnt end;
procedure P2ShowHitPercent(X,Y: Integer; const SD: TSurfaceDesc; Percent: Byte); assembler;
asm POP EBP; JMP ShowHitPcnt end;

function P2DamageRole(Damage, DC: Integer): Integer; assembler;
asm JMP ExecuteDamageRole end;

type
  TP2CombatTurnFields = class(TObject)
    Reserved: array[4..48] of Byte;
    Turn: Byte;
  end;
  { Obsolete serialized behavior object, VMT +4C read at 55782176. }
  TP2LegacyBehaviorCalls = class(TObject)
    procedure Slot00; virtual; abstract;
    procedure Slot04; virtual; abstract;
    procedure Slot08; virtual; abstract;
    procedure Slot0C; virtual; abstract;
    procedure Slot10; virtual; abstract;
    procedure Slot14; virtual; abstract;
    procedure Slot18; virtual; abstract;
    procedure Slot1C; virtual; abstract;
    procedure Slot20; virtual; abstract;
    procedure Slot24; virtual; abstract;
    procedure Slot28; virtual; abstract;
    procedure Slot2C; virtual; abstract;
    procedure Slot30; virtual; abstract;
    procedure Slot34; virtual; abstract;
    procedure Slot38; virtual; abstract;
    procedure Slot3C; virtual; abstract;
    procedure Slot40; virtual; abstract;
    procedure Slot44; virtual; abstract;
    procedure Slot48; virtual; abstract;
    function Behavior: Byte; virtual; abstract;
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

{ needs: P1 draft TPlayer.GetBusy: Boolean, AL test at 5578263D. }
function P2PlayerBusy(Player: TPlayer): Boolean; assembler;
asm JMP TPlayer.GetBusy end;

function P2Translate(const Text: string): string; assembler;
asm JMP TranslateRStr end;

{ needs: P1 draft Format(const Text: string; const Args: array of const):
  string, open-array call and hidden result at 55782521. }
function P2Format(const Text: string; const Args: array of const): string; assembler;
asm POP EBP; JMP Format end;

resourcestring
  P2RefugeJoinRStr = 'This one begs to join your cause.';
  P2RefugeesJoinRStr = 'This group wishes to join your forces.';
  P2BribeUnitJoinRStr = 'For %s gold pieces, this one offers to join you.';
  P2BribeUnitsJoinRStr = 'For %s gold pieces, they offer to join you.';

type TP2ShortintPointer = ^Shortint;
  TP2MapPlayerFields = class(TObject)
    Reserved: array[4..164] of Byte;
    Player: Shortint;
  end;

{ Rank and morale tables read at 557829DD..55782B75. }
const
  P2RankDefense: array[TUnitRank] of Shortint = (0,1,1);
  P2RankAttack: array[TUnitRank] of Shortint = (0,1,1);
  P2RankDamage: array[TUnitRank] of Shortint = (0,0,1);
  P2RankResistance: array[TUnitRank] of Shortint = (0,0,1);
  P2RankHits: array[TUnitRank] of Shortint = (0,1,2);
  P2MoraleResistance: array[TMorale] of Shortint = (-2,-1,0,0,0);
  P2MoraleDefense: array[TMorale] of Shortint = (-2,-1,0,0,0);

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

{ needs: P1 draft TFaceResourceList.GetFaceResource(Index: Integer):
  TFaceResource, pointer test at 5578288D. }
function P2FaceResource(List: TFaceResourceList; Index: Integer): TFaceResource; assembler;
asm JMP TFaceResourceList.GetFaceResource end;

type
  TP2FaceEnchantmentFields = class(TObject)
    Reserved: array[4..31] of Byte;
    FaceIndex: Integer;
  end;

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
        TRaceResourceList(P2AoWHSSet.FRaceResources),
        Shortint(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers), Player).FPlayerRace)))];
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
     not (msEditting in AoWHSMap.Status) then
  begin
    Race := GetRace;
    Morale := GetRelationValue(Player, IndependentRelation);
    if Race <> -1 then
    begin
      GetLocation(Xhx, Yhx, Lhx);
      if Xhx <> -1 then
      begin
        TerrainType := TAoWTerrainType(AoWHSMap.MapContainer.GetField(Xhx, Yhx, Lhx).TerrainType);
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

procedure TAbstractUnit.UpdateEnchanted;
var
  I: Integer;
  List: TAbilityTypeList;
  Enchanted: Boolean;
begin
  List := TP2AbilityControlFields(P2AoWHSSet.FAbilityControl).Enchantments;
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
  List := TP2AbilityControlFields(P2AoWHSSet.FAbilityControl).Enchantments;
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

procedure TAbstractUnit.RegisterEnchantments;
var
  Ability: TAbility;
  I: Integer;
  List: TAbilityTypeList;
  Data: TUnitEnchantmentAbilityData;
begin
  List := TP2AbilityControlFields(P2AoWHSSet.FAbilityControl).Enchantments;
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
  List := TP2AbilityControlFields(P2AoWHSSet.FAbilityControl).Enchantments;
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

function TAbstractUnit.AbilityToEnchantment(AbilityID: Integer): TUnitEnchantment;
var
  Ability: TAbility;
  Data: TUnitEnchantmentAbilityData;
begin
  Ability := P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl), AbilityID);
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
  List := TP2AbilityControlFields(P2AoWHSSet.FAbilityControl).Enchantments;
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
  Abilities := TP2AbilityControlFields(P2AoWHSSet.FAbilityControl).Enchantments;
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
    Result := TP2AbilityCalls(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl), AbilityID)).AbilityInherent(Self);
    Exit;
  end;
  Result := False;
end;

function TAbstractUnit.GetInherentAbilityLevel(AbilityID: Integer): Shortint;
begin
  if TP2AbilityCalls(Self).GetAbSet(AbilityID) then
  begin
    Result := TP2AbilityCalls(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl), AbilityID)).AbilityInherentLevel(Self);
    Exit;
  end;
  Result := 0;
end;

function TAbstractUnit.GetAbilityEnabled(AbilityID: Integer): Boolean;
begin
  if GetAbilitySet(AbilityID) then
  begin
    Result := TP2AbilityCalls(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl), AbilityID)).AbilityEnabled(Self);
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
  Result := TP2AbilityCalls(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl), AbilityID)).AbilityName(Self);
end;

function TAbstractUnit.GetAbilityLevel(AbilityID: Integer): Integer;
begin
  Result := TP2AbilityCalls(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl), AbilityID)).AbilityLevel(Self);
end;

function TAbstractUnit.GetAbilityOwner(AbilityID: Integer): TAbilityOwner;
begin
  if TP2AbilityCalls(Self).GetAbSet(AbilityID) then
  begin Result := Self; Exit; end;
  Result := nil;
end;

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

procedure TAbstractUnit.UpdateOffensiveStrength;
var
  DamageType: TDamageType;
  Ability: TP2AbilityCalls;
  DamageTypes: TDamageTypes;
  I, Strength: Integer;
  Abilities: TAbilityTypeList;
begin
  Abilities := TP2AbilityControlFields(P2AoWHSSet.FAbilityControl).CombatAbilities;
  FMaxOffensiveStrength := 0;
  FillChar(FOffensiveStrength, SizeOf(FOffensiveStrength), 0);
  for I := Abilities.Count - 1 downto 0 do
  begin
    Ability := P2VMTAbility(Abilities, I);
    if GetAbilityEnabled(Ability.AbilityID) then
    begin
      Ability.OffensiveStrength(Self, Strength, DamageTypes);
      if Strength > 255 then Strength := 255;
      Assert(DamageTypes <> [], 'Ability: ' + Ability.AbilityName(nil));
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
  Ability: TP2AbilityCalls;
  Info: TP2DamageValue;
begin
  Result := 0;
  Abilities := TP2AbilityControlFields(P2AoWHSSet.FAbilityControl).CombatAbilities;
  for I := Abilities.Count - 1 downto 0 do
  begin
    Ability := P2VMTAbility(Abilities, I);
    if GetAbilityEnabled(Ability.AbilityID) then
    begin
      Ability.DamageValueEx(Self, Target, Mode, Info);
      if Info.Damage > 0 then
      begin
        Value := Info.Damage;
        Value := Value * Value div (Info.Cost + Value);
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
  TypeName: string;
  Name, Source: string;
begin
  Names.Clear;
  if Sources <> nil then Sources.Clear;
  for I := 0 to GetAbilityCount - 1 do
    if GetAbilitySet(I) then
    begin
      AOwner := GetAbilityOwner(I);
      Ability := TP2AbilityCalls(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl), I));
      Name := Ability.AbilityName(AOwner);
      if Name <> '' then Names.AddObject(Name, TObject(I));
      if Types <> nil then
      begin
        P2TranslateRStr(P2AbilityTypeNames[TP2AbilityCalls(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl), I)).AbilityType], TypeName);
        Types.AddObject(TypeName, TObject(I));
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

function TAbstractUnit.GetUpkeep: Shortint;
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

function TAbstractUnit.GetImmunityTypes: TDamageTypes;
begin
  Result := P2AbImmunity(Self) + [dtWall];
end;

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

procedure TAbstractUnit.CreateMovePointTable(var Table: TP2MovePointTable);
var
  Moves: TMoveTypes;
  Terrain: Integer;
  Overlay: Shortint;
  Points: Integer;
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
            if Table[Terrain,Overlay] > 2 then
              Table[Terrain,Overlay] := (Integer(Table[Terrain,Overlay]) + 1) shr 1;
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
          if Table[Terrain,Overlay] > 0 then Inc(Table[Terrain,Overlay],2);
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

procedure TAbstractUnit.ExecuteTrailOfDarkness(MapField: TMapField);
var
  Level: TMapLevel;
  Walk: THNWalkData;
  Field: TAoWMapField;
  Player: Integer;
begin
  Level := TMapLevel(MapField.Owner);
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
  Cost: Integer;
  Army: TArmy;
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
    Army := TArmy(Owner);
    if not ((Army is TArmy) and (Army.Transporter($FF) <> nil)) then
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

function TAbstractUnit.ConcealedOnMapF(Field: TAoWMapField): Boolean;
begin
  if not GetAbilityEnabled(54) and not P2ConcealmentActive(Field) then
  begin
    Result := GetAbilityEnabled(139) and (Field.Lhx <> 0);
    if (Smallint(Field.OverlayType) = 1) and (GetAbilityEnabled(145) or GetAbilityEnabled(162)) then
      Result := True
    else
      { Original terrain branches overwrite the underground concealment result. }
      case Smallint(Field.TerrainType) of
        1: Result := GetAbilityEnabled(140);
        3: Result := GetAbilityEnabled(141);
        2: Result := GetAbilityEnabled(142);
        5: Result := GetAbilityEnabled(143);
        0,10: Result := GetAbilityEnabled(144);
        4: Result := GetAbilityEnabled(138);
      end;
  end
  else Result := True;
end;

function TAbstractUnit.ExecuteStormDamage(Storm: TStormType): Integer;
var
  Overlay: Shortint;
  Moves: TMoveTypes;
  Xhx,Yhx,Lhx: Shortint;
  Field: TMapField;
  Terrain: Shortint;
  DoubleDamage: Boolean;
  Attack, Damage: Integer;
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
    stFire: begin Attack := 7; Damage := 5; end;
    stLightning: begin Attack := 8; Damage := 7; end;
    stDeath: begin Attack := 7; Damage := 4; end;
    stHoly: begin Attack := 7; Damage := 5; end;
    stIce: begin Attack := 7; Damage := 5; end;
    stPestilence: begin Attack := 4; Damage := 3; end;
  else Attack := 0; Damage := 0;
  end;
  if DoubleDamage then Damage := Damage * 2;
  Damage := ExecuteDamageRole(Attack,Damage,[P2StormDamageType[Storm]]);
  if Damage > GetHitPoints then Damage := GetHitPoints;
  if Damage > 0 then
    case Storm of
      stDeath: ExecuteDamageEffects([dtDeath]);
      stPestilence: ExecuteDamageEffects([dtPoison]);
    end;
  SetHitPoints(GetHitPoints - Damage);
  Result := Damage;
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
      Enchantment.Duration := TP2SpellFields(P2Spell(TSpellControl(P2AoWHSSet.FSpellControl),17)).Duration;
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
      Enchantment.Duration := TP2SpellFields(P2Spell(TSpellControl(P2AoWHSSet.FSpellControl),56)).Duration;
    end;
end;

procedure TAbstractUnit.ResetLifeMasteryFear;
begin
  if GetAbilityEnabled(53) then
    if TUnitEnchantmentAbilityData(P2AbilityData(Self,53)).FEnchantment = TUnitEnchantment(1) then
      RemoveAbility(53);
end;

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

procedure TAbstractUnit.Changed;
var
  List: TECustomNode;
begin
  if usActivated in FUnitStatus then
  begin
    UpdateMoraleValue;
    UpdateOffensiveStrength;
    UpdateDefensiveStrength;
    UpdateEnchanted;
    if AoWHSMap <> nil then P2UnitChanged(AoWHSMap,Self);
  end;
  List := Owner;
  if (List <> nil) and (List is TUnitList) then TUnitList(List).Changed;
end;

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

procedure TAbstractUnit.ValidateCrusader;
var
  Data: TDurationAbilityData;
begin
  Data := TDurationAbilityData(P2AbilityData(Self,101));
  if Data <> nil then
    if Data.FDuration <= 0 then Killed;
end;

procedure TAbstractUnit.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
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

function TAbstractUnit.ShowEx(X,Y: Integer; const SD: TSurfaceDesc; const Info: TP2UnitShowInfo): Integer;
var
  Sequence: TImageSequence;
  Frame, TotalFrames, ResourceIndex: Integer;
begin
  Result := 0;
  ResourceIndex := GetUnitGFXResourceIndex;
  TUnitGFXResourceList(P2AoWHSSet.FUnitGFXResources).GetUnitGFXResource(ResourceIndex).AddRef;
  if Info.Animation <> uaNone then
  begin
    Sequence := TImageSequence(TUnitGFXResourceList(P2AoWHSSet.FUnitGFXResources).GetUnitGFXResource(ResourceIndex).FSequences.List^[Ord(Info.Animation) * 6 + Info.Direction - 1]);
    if Sequence <> nil then
    begin
      if not Info.Looped then
      begin
        TotalFrames := Sequence.GetTotalSequenceFrames;
        Frame := Sequence.GetUnloopedFrameIndex(Info.Frame);
        if Frame >= 0 then
          Sequence.ImageLibrary[Frame].Show(X + Sequence.dXshift + 16,Y + Sequence.dYshift + 20,SD)
        else
          TUnitGFXResourceList(P2AoWHSSet.FUnitGFXResources).GetUnitGFXResource(ResourceIndex).Show(Info.Direction,X + Sequence.dXshift + 16,Y + Sequence.dYshift + 20,SD);
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
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),96).FImageSequences).ShowLooped(0,X+32,Y+32,AoWHSMap.Frame,SD)
    else
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),96).FImageSequences).Show(0,X+32,Y+32,4,SD);
  if GetAbilityEnabled(98) then
    if Info.Looped then
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),98).FImageSequences).ShowLooped(0,X+32,Y+32,AoWHSMap.Frame,SD)
    else
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),98).FImageSequences).Show(0,X+32,Y+32,4,SD);
  if GetAbilityEnabled(93) then
    if Info.Looped then
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),93).FImageSequences).ShowLooped(0,X+32,Y+32,AoWHSMap.Frame,SD)
    else
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),93).FImageSequences).Show(0,X+32,Y+32,4,SD);
  if uoHitPoints in Info.Overlays then
    P2ShowHitPercent(X,Y,SD,P2HitPercent(GetHitPoints,GetHits));
  if uoCombat in Info.Overlays then
  begin
    if GetHitPoints = 0 then
      TCustomImageLibrary(P2AoWHSSet.FCombatImages)[4].Show(X+18,Y+10,SD);
    if GetAbilityEnabled(48) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),48).FImageSequences).ShowLooped(0,X+32,Y+40,AoWHSMap.Frame,SD);
    if GetAbilityEnabled(150) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),150).FImageSequences).ShowLooped(0,X+32,Y+40,AoWHSMap.Frame,SD);
    if GetAbilityEnabled(149) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),149).FImageSequences).ShowLooped(0,X+32,Y+40,AoWHSMap.Frame,SD);
    if GetAbilityEnabled(97) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),97).FImageSequences).ShowLooped(0,X+32,Y+40,AoWHSMap.Frame,SD);
    if GetAbilityEnabled(92) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),92).FImageSequences).ShowLooped(0,X+32,Y+35,AoWHSMap.Frame,SD);
    if GetAbilityEnabled(95) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),95).FImageSequences).ShowLooped(0,X+32,Y+32,AoWHSMap.Frame,SD);
    if GetAbilityEnabled(94) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),94).FImageSequences).ShowLooped(0,X+32,Y+35,AoWHSMap.Frame,SD);
    if GetAbilityEnabled(127) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),127).FImageSequences).ShowLooped(0,X+32,Y+35,AoWHSMap.Frame,SD);
    if GetAbilityEnabled(107) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),107).FImageSequences).ShowLooped(0,X+32,Y+40,AoWHSMap.Frame,SD);
    if GetAbilityEnabled(34) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),34).FImageSequences).ShowLooped(0,X+32,Y+40,AoWHSMap.Frame,SD);
  end;
  if usEnchanted in FUnitStatus then
    if Info.Looped then
      TImageSequenceList(P2AoWHSSet.FImageSequences).ShowLooped(70,X+32,Y+40,AoWHSMap.Frame,SD)
    else
      TImageSequenceList(P2AoWHSSet.FImageSequences).Show(70,X+32,Y+40,5,SD);
  TUnitGFXResourceList(P2AoWHSSet.FUnitGFXResources).GetUnitGFXResource(ResourceIndex).Release;
end;

procedure TAbstractUnit.ShowFace(const R: TRect; const SD: TSurfaceDesc);
var
  Image: TLibraryImage;
begin
  Image := GetFace;
  if Image <> nil then Image.ShowStretched(R,SD);
  if GetAbilityEnabled(129) then
    if AoWHSMap <> nil then
      if TCustomImageLibrary(P2AoWHSSet.FGeneralImages)[45] <> nil then
        TCustomImageLibrary(P2AoWHSSet.FGeneralImages)[45].ShowStretched(R,SD);
end;

function TAbstractUnit.ExecuteDamageRole(Attack, Damage: Integer; DamageTypes: TDamageTypes): Integer;
var
  Active: TDamageTypes;
begin
  Result := 0;
  Active := DamageTypes - GetImmunityTypes;
  if Active <> [] then
  begin
    Result := P2DamageRole(Damage, Attack - GetDefense);
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
  if Active <> [] then
  begin
    if (dtPoison in Active) and TP2OwnerCalls(Self).Expand(96) then
      Result := Result + [dtPoison];
    if (dtDeath in Active) and TP2OwnerCalls(Self).Expand(93) then
      Result := Result + [dtDeath];
    if (dtHoly in Active) and TP2OwnerCalls(Self).Expand(98) then
      Result := Result + [dtHoly];
  end;
end;

function TAbstractUnit.ExecuteCombatDamageEffects(Combat: TCombat; DamageTypes: TDamageTypes): TDamageTypes;
var
  Active: TDamageTypes;
  Data: TUnitEnchantmentAbilityData;
begin
  Result := [];
  Active := DamageTypes - GetImmunityTypes;
  if Active <> [] then
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

function TAbstractUnit.CanJoin(Player: Shortint): Boolean;
var
  Alignment: TAlignment;
  Relation: TDiplomaticRelation;
  I: Integer;
  Group: TUnitUserList;
begin
  Group := FGroup;
  if (Group = nil) or not (TP2AbilityCalls(Group).GroupBehavior in [gbGuard,gbGuardArea]) then
  begin
    if GetRace = -1 then
    begin
      Alignment := P2GetRaceAlignment(P2GetRaceResource(TRaceResourceList(P2AoWHSSet.FRaceResources),
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
              (TIntegerList(P2GetRaceResource(TRaceResourceList(P2AoWHSSet.FRaceResources),I).FUnitIndexes).
                IndexOf(TUnitResource(TUnit(Self).FUnitResource).UnitResourceIndex) <> -1);
          end;
        end
        else Result := Relation = drPeace;
      end
      else Result := True;
    end
    else Result := P2RacePlayerRelation(P2GetRace(TRaceList(AoWHSMap.FRaces),GetRace),Player) >= sPolite;
    if Result and (FGroup <> nil) and (TP2AbilityCalls(FGroup).GroupBehavior = gbHunt) and
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
        Alignment := P2GetRaceAlignment(P2GetRaceResource(TRaceResourceList(P2AoWHSSet.FRaceResources),
          Shortint(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),Player).FPlayerRace)));
        if ((GetAlignment <> alNone) or (GetUnitType = utMachine)) and
          (P2AlignmentDiplomaticRelation(GetAlignment,Alignment) <> drPeace) then Result := False
        else Result := True;
      end
      else Result := False;
    end
  else Result := False;
end;

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
      urSilver: TCustomImageLibrary(P2AoWHSSet.FCombatImages)[5].Show(X+33,Y+12,SD);
      urGold: TCustomImageLibrary(P2AoWHSSet.FCombatImages)[6].Show(X+33,Y+12,SD);
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
  UnitKilled;
  SetOwner(nil);
end;

procedure TUnit.UnitKilled;
begin end;

function TUnit.GetFace: TLibraryImage;
var
  FaceIndex: Integer;
begin
  if not GetAbilityEnabled(126) then
  begin
    Result := TUnitGFXResourceList(P2AoWHSSet.FUnitGFXResources).GetUnitGFXResource(FUnitResource.FUnitGFXResourceIndex).GetFaceImage;
    Exit;
  end;
  FaceIndex := TP2FaceEnchantmentFields(TUnitEnchantmentAbilityData(P2AbilityData(Self,126)).FEnchantment).FaceIndex;
  if P2FaceResource(TFaceResourceList(P2AoWHSSet.FFaceResources),FaceIndex) <> nil then
    Result := P2FaceResource(TFaceResourceList(P2AoWHSSet.FFaceResources),FaceIndex).GetCellImage
  else Result := nil;
end;

function TUnit.GetExperience: Integer;
begin Result := FExperience; end;

procedure TUnit.SetExperience(Value: Integer);
var
  OldRank, Rank: TUnitRank;
begin
  OldRank := GetRank;
  if Value > 255 then Value := 255;
  FExperience := Value;
  if GetRank <> OldRank then
    for Rank := Succ(OldRank) to GetRank do
      UpdateDefaultAbilities(FUnitResource.FAbilities[Rank]);
  Changed;
end;

function TUnit.GetDescription: TStrings;
begin Result := FUnitResource.FDescription; end;

function TUnit.GetNextLevelExperience: Integer;
begin
  if FExperience >= FUnitResource.FLevel * 2 then
    if FExperience >= FUnitResource.FLevel * 6 then Result := 0
    else begin Result := FUnitResource.FLevel * 6; Exit; end
  else Result := FUnitResource.FLevel * 2;
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
    Clear;
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

procedure TUnit.ReadWrite(Stream: Engine.TEStorageStream);
var
  ResourceIndex: Smallint;
  Resource: TUnitResource;
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(FExperience,7);
  Stream.rwByte(Byte(FMovePoints),8);
  Stream.rwByte(Byte(FHitPoints),9);
  if Stream.StorageMode * [smWrite,smTextOnly] = [smWrite] then
    if smCompare in Stream.StorageMode then
    begin
      ResourceIndex := FUnitResource.UnitResourceIndex;
      Stream.rwWord(Word(ResourceIndex),10);
    end
    else if smRead in Stream.StorageMode then
    begin
      Stream.rwWord(Word(ResourceIndex),10);
      Resource := TUnitResourceList(P2AoWHSSet.FUnitResources).GetUnitResource(ResourceIndex);
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

function P2CompareUnitMoves(Item1, Item2: Pointer): Integer;
begin
  Result := TAbstractUnit(Item2).GetMoves - TAbstractUnit(Item1).GetMoves;
end;

procedure TUnitList.SortUnits;
begin
  LockChanged;
  FChildren.Pack;
  FChildren.Sort(P2CompareUnits);
  UnlockChanged;
end;

procedure TUnitList.SortOnMoves;
begin
  LockChanged;
  FChildren.Pack;
  FChildren.Sort(P2CompareUnitMoves);
  UnlockChanged;
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
    FUnits.Insert(N + Collection * FCollectionSize, UnitIndex);
    Result := True;
  end
  else Result := False;
end;

procedure TUnitIndexListCollection.DeleteUnit(Collection, Index: Integer);
var
  N: Integer;
begin
  N := GetCollectionCount(Collection);
  if Index < N then
  begin
    FUnits.Delete(Collection * FCollectionSize + Index);
    FUnits.Insert(Collection * FCollectionSize + N - 1, -1);
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

resourcestring
  P2WoodenWallRStr = 'Wooden Wall';
  P2StoneWallRStr = 'Stone Wall';
  P2UndefinedWallRStr = 'Undefined';

procedure TWallUnit.SetWallType(Value: TWallType);
var
  WallType: TWallType;
begin
  WallType := Value;
  FWallType := WallType;
  if WallType = wtStone then FHits := 10 else FHits := 5;
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
    Result := FFaceImageLibrary.GetImage(FFaceIndex)
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
  SetControlStyle([csKeepIndex]);
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
    with FShadow do FUnitHS := Self;
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
  if Resource <> nil then begin Result := Resource.GetIndex; Exit; end;
  Result := -1;
end;


procedure TUnitHS.SetUnitGFXResourceIndex(Value: Integer);
var
  Resource: TUnitGFXResource;
begin
  Resource := FUnitGFXResource;
  if (Resource = nil) or (Value <> Resource.GetIndex) then
  begin
    Resource := FUnitGFXResource;
    if Resource <> nil then Resource.Release;
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


procedure TUnitHS.Disconnect;
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


function TUnitHS.PlaceHX(Map: TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
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
        { ImageLib's private speed counter at $30 gates the original footstep sound. }
        asm
          MOV EAX, Sequence
          MOV DL, [EAX + $30]
          CMP DL, [EAX + $18]
          JNE @@NoStepSound
          MOV EAX, Index
          MOV ECX, 100
          CDQ
          IDIV ECX
          MOV EAX, Self
          MOV EAX, [EAX + $10]
          MOV EAX, [EAX + $38]
          CALL TSFXLibrary.Play
        @@NoStepSound:
        end;
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


function TUnitHS.MoveFirst(Direction: Byte; Instant: Boolean): Shortint;
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


function TUnitResourceAbilityOwner.GetAbilitySelectionTypes: TAbilitySelectionTypes;
begin Result := []; end;

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


function TUnitResource.UnitResourceIndex: Integer;
begin Result := Owner.FindChildIndex(Self); end;


class function TUnitResource.ClassID: Integer;
begin Result := $20212; end;


function TUnitResource.GetUnitName: string;
begin
  Result := FName;
  if FNickname <> '' then Result := Result + ' ' + FNickname;
end;


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
  { Original checks Item1 twice before reading Item2. }
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

constructor THeroUpgradeTE.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilities := TAbilityOwner.Create(nil);
end;

destructor THeroUpgradeTE.Destroy;
begin
  FAbilities.Free;
  inherited Destroy;
end;

procedure THeroUpgradeTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FAttack), 30);
  Stream.rwByte(Byte(FDefense), 31);
  Stream.rwByte(Byte(FResistance), 32);
  Stream.rwByte(Byte(FDamage), 33);
  Stream.rwByte(Byte(FMoves), 34);
  Stream.rwByte(Byte(FHits), 35);
  Stream.rwEObject(FAbilities, 36);
  Stream.rwInteger(FUnitID, 37);
  Stream.rwByte(Byte(FPlayer), 38);
end;

class function THeroUpgradeTE.ClassID: Integer;
begin Result := $2131D; end;

function THeroUpgradeTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
var Hero: THero;
begin
  Result := inherited Execute(TE);
  Hero := THero(AoWHSMap.FUnitControl.FindUnit(FUnitID));
  if (Hero <> nil) and (Hero.GetHitPoints <> 0) and (Hero.FPlayer = FPlayer) then
  begin
    Hero.SetUnitAttack(Hero.FUnitAttack + FAttack);
    Hero.SetUnitDefense(Hero.FUnitDefense + FDefense);
    Hero.SetUnitResistance(Hero.FUnitResistance + FResistance);
    Hero.SetUnitDamage(Hero.FUnitDamage + FDamage);
    Hero.SetUnitMoves(Hero.FUnitMoves + FMoves);
    Hero.SetUnitHits(Hero.FUnitHits + FHits);
    Hero.UpdateDefaultAbilities(FAbilities);
    Hero.FUpgradePending := False;
  end;
end;

procedure THeroUpgradeTE.Setup(Hero: THero);
begin
  FUnitID := Hero.FUnitID;
  FPlayer := Hero.FPlayer;
end;

resourcestring
  XMadeALevelRStr = '%s made a level';
  XMadeYLevelsRStr = '%s made %d levels';
  CanOnlyUpgradeHeroOnceRStr = 'Can only upgrade hero once';
  CanOnlyUpgradeOnTheDayALevelIsMadeRStr = 'Can only upgrade on the day a level is made';
  XOffersToJoinRStr = '%s offers to join!';
  XAlreadyJoinedRStr = '%s already joined';
  XDoesntWantToJoinAnymoreRStr = '%s doesn''t want to join anymore';
  XEmergedAtYAndOffersToJoinYouForZgpRStr = '%0:s emerged at %1:s and offers to join you for %d gold';
  XwasResurrectedAndOffersToJoinYouForZgpRStr = '%s was resurrected and offers to join you for %d gold';

class function THeroUpgradeEventLog.ClassID: Integer;
begin Result := $202F1; end;

procedure THeroUpgradeEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FUnitID, 25);
  Stream.rwByte(FOldLevel, 26);
  Stream.rwByte(FNewLevel, 27);
  Stream.rwInteger(FDay, 28);
end;

function THeroUpgradeEventLog.GetText: string;
var Hero: THero;
begin
  Hero := THero(AoWHSMap.FUnitControl.FindUnit(FUnitID));
  if Hero <> nil then
    if FNewLevel - FOldLevel = 1 then
      Result := Format(TranslateRStr(XMadeALevelRStr), [Hero.GetName])
    else Result := Format(TranslateRStr(XMadeYLevelsRStr), [Hero.GetName, FNewLevel - FOldLevel]);
end;

function THeroUpgradeEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
var Hero: THero;
begin
  Hero := THero(AoWHSMap.FUnitControl.FindUnit(FUnitID));
  if (Hero <> nil) and (AoWHSMap.FSeatedPlayer = Hero.FPlayer) then
  begin
    if Hero.FUpgradePending then
    begin
      Result := Trigger = etUser;
      Result := Result or ((AoWHSMap.FPlayMode = pmTurn) and
        (wpHeroUpgrade in TAoWRegistry(AoWEngine.FRegistry).GetClassicWindowPopupEvents));
      Result := Result or ((AoWHSMap.FPlayMode = pmSimultaneous) and
        (wpHeroUpgrade in TAoWRegistry(AoWEngine.FRegistry).GetSimultaneousWindowPopupEvents));
      if Result then Result := inherited Execute(Mode, Trigger, Done);
    end
    else
    begin
      if AoWHSMap.FPlayers.GetPlayers(Hero.FPlayer).FDay = FDay then
        AoWHSMap.ShowWarning(TranslateRStr(CanOnlyUpgradeHeroOnceRStr))
      else AoWHSMap.ShowWarning(TranslateRStr(CanOnlyUpgradeOnTheDayALevelIsMadeRStr));
      Result := False;
    end;
  end
  else Result := False;
end;

procedure THeroUpgradeEventLog.ViewLocation;
var U: TAbstractUnit; X, Y, L: Shortint;
begin
  U := AoWHSMap.FUnitControl.FindUnit(FUnitID);
  if U <> nil then
  begin
    U.GetLocation(X, Y, L);
    if X <> -1 then CenterViewTo(X, Y, L);
  end;
end;

class function THeroJoinEventLog.ClassID: Integer;
begin Result := $202F4; end;

function THeroJoinEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
var Hero: THero;
begin
  Hero := THero(AoWHSMap.FUnitControl.FindUnit(FFirstUnitID));
  if (Hero <> nil) and (Hero.FPlayer = 0) and Hero.OfferToJoin(FPlayer) then
  begin
    Result := Trigger = etUser;
    Result := Result or ((AoWHSMap.FPlayMode = pmTurn) and
      (wpHeroJoin in TAoWRegistry(AoWEngine.FRegistry).GetClassicWindowPopupEvents));
    Result := Result or ((AoWHSMap.FPlayMode = pmSimultaneous) and
      (wpHeroJoin in TAoWRegistry(AoWEngine.FRegistry).GetSimultaneousWindowPopupEvents));
    if Result then Result := inherited Execute(Mode, Trigger, Done);
  end
  else Result := False;
end;

function THeroJoinEventLog.ExecuteAI: Boolean;
var Hero: THero; ErrorText: string;
begin
  Result := False;
  Hero := THero(AoWHSMap.FUnitControl.FindUnit(FFirstUnitID));
  if (Hero <> nil) and (Hero.FPlayer = 0) and Hero.OfferToJoin(FPlayer) then
    if AoWHSMap.FPlayers.GetPlayers(FPlayer).FAIBudget.RequestBudgetExpense(
      FGold, 0, AoWHSMap.FPlayers.GetPlayers(FPlayer).FAIBudget.FDefaultBudget, True) then
    begin
      if Accept(ErrorText) then
        AoWHSMap.FPlayers.GetPlayers(FPlayer).FAIBudget.BudgetExpenseMade(
          FGold, 0, AoWHSMap.FPlayers.GetPlayers(FPlayer).FAIBudget.FDefaultBudget, bemBudgetThenPool);
      Result := True;
    end;
end;

function THeroJoinEventLog.Accept(var ErrorText: string): Boolean;
var TE: TNegotiateTE; U: TAbstractUnit; Location: TXYL;
begin
  Result := inherited Accept(ErrorText);
  if Result and not AoWHSMap.FPlayers.GetPlayers(FPlayer).GetBusy then
  begin
    U := AoWHSMap.FUnitControl.FindUnit(FFirstUnitID);
    U.GetLocation(Location.X, Location.Y, Location.L);
    TE := TNegotiateTE.Create(nil);
    TE.FPlayer := FPlayer;
    TE.FObject := noArmy;
    TE.FGold := FGold;
    TE.FOffer := noOfferBribe;
    TE.FX := Location.X;
    TE.FY := Location.Y;
    TE.FL := Location.L;
    TE.FMode := [];
    TE.FResult := nrAccept;
    TE.FEventLogID := FJoinIndex;
    AoWHSMap.FTokenManager.GetTokenControl(FPlayer).AddEvent(TE);
    TE.Release;
  end;
end;

class function THeroEmergeEventLog.ClassID: Integer;
begin Result := $202F8; end;

procedure THeroEmergeEventLog.Setup(Hero: THero; Player: Shortint; Mode: THeroJoinMode);
var Name: string;
begin
  FPlayer := Player;
  FUnitID := Hero.FUnitID;
  FDay := AoWHSMap.FDay;
  FMode := Mode;
  Name := Hero.FHeroName;
  if Hero.GetNickname <> '' then Name := Name + ' ' + Hero.GetNickname;
  { Original builds Name but formats the message from FHeroName instead. }
  FText := Format(TranslateRStr(XOffersToJoinRStr), [Hero.FHeroName]);
end;

procedure THeroEmergeEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FUnitID, 39);
  Stream.rwInteger(FDay, 40);
  Stream.rwString(FText, 41);
  Stream.rwString(FLocationName, 42);
  Stream.rwData(FMode, 1, 43);
end;

function THeroEmergeEventLog.GetText: string;
begin
  Result := FText;
end;

procedure THeroEmergeEventLog.ViewLocation;
var U: TAbstractUnit; X, Y, L: Shortint;
begin
  U := AoWHSMap.FUnitControl.FindUnit(FUnitID);
  if U <> nil then
  begin
    U.GetLocation(X, Y, L);
    if X <> -1 then CenterViewTo(X, Y, L);
  end;
end;

function THeroEmergeEventLog.CreateHeroJoinEventLog: THeroJoinEventLog;
var Hero: THero;
begin
  Hero := THero(AoWHSMap.FUnitControl.FindUnit(FUnitID));
  if (Hero <> nil) and (Hero.FPlayer = 0) and Hero.OfferToJoin(FPlayer) then
  begin
    Result := THeroJoinEventLog.Create(nil);
    Result.FJoinIndex := FID;
    case FMode of
    hjmEmerged:
    begin
      Result.SetupJoinArmy(TArmy(Hero.Owner), FPlayer, Result.FJoinMode);
      Result.FFirstUnitID := Hero.FUnitID;
      Result.FJoinMessage.Text := Format(TranslateRStr(XEmergedAtYAndOffersToJoinYouForZgpRStr),
        [Hero.FHeroName, FLocationName, Result.FGold]);
    end;
    hjmResurrected:
    begin
      Result.SetupJoinArmy(TArmy(Hero.Owner), FPlayer, Result.FJoinMode);
      Result.FFirstUnitID := Hero.FUnitID;
      Result.FJoinMessage.Text := Format(TranslateRStr(XwasResurrectedAndOffersToJoinYouForZgpRStr),
        [Hero.FHeroName, Result.FGold]);
    end;
    end;
  end
  else Result := nil;
end;

function THeroEmergeEventLog.ExecuteAI: Boolean;
var Log: THeroJoinEventLog;
begin
  Log := CreateHeroJoinEventLog;
  if Log <> nil then
  begin
    Result := Log.ExecuteAI;
    Log.Release;
  end
  else Result := False;
end;

function THeroEmergeEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
var Log: THeroJoinEventLog; Hero: THero;
begin
  Log := CreateHeroJoinEventLog;
  if Log <> nil then
  begin
    Result := Log.Execute(Mode, Trigger, Done);
    Log.Release;
  end
  else
  begin
    Hero := THero(AoWHSMap.FUnitControl.FindUnit(FUnitID));
    if Hero <> nil then
      if Hero.FPlayer = FPlayer then
        AoWHSMap.ShowWarning(Format(TranslateRStr(XAlreadyJoinedRStr), [Hero.FHeroName]))
      else AoWHSMap.ShowWarning(Format(TranslateRStr(XDoesntWantToJoinAnymoreRStr), [Hero.FHeroName]));
    Result := False;
  end;
end;

constructor THeroInventory.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(nil);
  FOwner := AOwner;
end;

destructor THeroInventory.Destroy;
begin
  FOwner := nil;
  inherited Destroy;
end;

function THeroInventory.GetFreeSlot: Integer;
begin
  Result := 0;
  while (Result < FChildren.Count) and (Result <> 8) do
  begin
    if FChildren.List^[Result] = nil then Exit;
    Inc(Result);
  end;
  Result := -1;
end;

function THeroInventory.GetControlStyle: Engine.TEControlStyles;
begin
  Result := inherited GetControlStyle + [csArrayMode];
end;

procedure THeroInventory.GetLocation(var X, Y, L: Shortint);
begin
  TAbstractUnit(FOwner).GetLocation(X, Y, L);
end;

function THeroInventory.GetAbilityCount: Integer;
var I: Integer; Item: TItem;
begin
  Result := 0;
  for I := 0 to Count - 1 do
  begin
    Item := TItem(FChildren.List^[I]);
    if (Item <> nil) and (Result < Item.GetAbCount) then Result := Item.GetAbCount;
  end;
end;

function THeroInventory.GetSuperlativeEnabledAbOwner(AbilityID: Integer): TAbilityOwner;
var I: Integer; Item: TItem;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    Item := TItem(FChildren.List^[I]);
    if (Item <> nil) and Item.GetAbEnabled(AbilityID) and (Item.FItemType = itUse) then
      if (Result = nil) or (Item.GetAbLevel(AbilityID) > Result.GetAbLevel(AbilityID)) then
        Result := Item;
  end;
end;

function THeroInventory.GetAbilityEnabled(AbilityID: Integer): Boolean;
var I: Integer; Item: TItem;
begin
  Result := False;
  I := 0;
  while not Result and (I < Count) do
  begin
    Item := TItem(FChildren.List^[I]);
    Result := (Item <> nil) and (Item.FItemType = itUse) and Item.GetAbEnabled(AbilityID);
    Inc(I);
  end;
end;

function THeroInventory.GetAbilitySet(AbilityID: Integer): Boolean;
var I: Integer; Item: TItem;
begin
  Result := False;
  I := 0;
  while not Result and (I < Count) do
  begin
    Item := TItem(FChildren.List^[I]);
    Result := (Item <> nil) and (Item.FItemType = itUse) and Item.GetAbSet(AbilityID);
    Inc(I);
  end;
end;

function THeroInventory.GetSuperlativeAbOwner(AbilityID: Integer): TAbilityOwner;
var I: Integer; Item: TItem;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    Item := TItem(FChildren.List^[I]);
    if (Item <> nil) and Item.GetAbSet(AbilityID) and (Item.FItemType = itUse) then
      if (Result = nil) or (Item.GetAbLevel(AbilityID) > Result.GetAbLevel(AbilityID)) then
        Result := Item;
  end;
end;

function THeroInventory.GetSlot(Position: THeroItemPosition): TItem;
var I: Integer;
begin
  case Position of
    ipInventorySlot1..ipInventorySlot8:
    begin
      I := Ord(Position) - Ord(ipInventorySlot1);
      if (I < Count) and (I >= 0) then Result := GetItem(I)
      else
      begin
        Result := nil;
        Exit;
      end;
    end;
  else Result := nil;
  end;
end;

constructor THeroItems.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(nil);
  FOwner := AOwner;
end;

destructor THeroItems.Destroy;
begin
  FOwner := nil;
  inherited Destroy;
end;

function THeroItems.GetControlStyle: Engine.TEControlStyles;
begin
  Result := inherited GetControlStyle + [csArrayMode];
end;

procedure THeroItems.GetLocation(var X, Y, L: Shortint);
begin
  TAbstractUnit(FOwner).GetLocation(X, Y, L);
end;

function THeroItems.GetAttack: Shortint;
var I: Integer; Item: TItem;
begin
  Result := 0;
  for I := 0 to Count - 1 do
  begin
    Item := TItem(FChildren.List^[I]);
    if Item <> nil then Inc(Result, Item.FAttack);
  end;
end;

function THeroItems.GetDefense: Shortint;
var I: Integer; Item: TItem;
begin
  Result := 0;
  for I := 0 to Count - 1 do
  begin
    Item := TItem(FChildren.List^[I]);
    if Item <> nil then Inc(Result, Item.FDefense);
  end;
end;

function THeroItems.GetDamage: Shortint;
var I: Integer; Item: TItem;
begin
  Result := 0;
  for I := 0 to Count - 1 do
  begin
    Item := TItem(FChildren.List^[I]);
    if Item <> nil then Inc(Result, Item.FDamage);
  end;
end;

function THeroItems.GetResistance: Shortint;
var I: Integer; Item: TItem;
begin
  Result := 0;
  for I := 0 to Count - 1 do
  begin
    Item := TItem(FChildren.List^[I]);
    if Item <> nil then Inc(Result, Item.FResistance);
  end;
end;

function THeroItems.GetMoveTypes: TMoveTypes;
var I: Integer; Item: TItem;
begin
  Result := [];
  for I := 0 to Count - 1 do
  begin
    Item := TItem(FChildren.List^[I]);
    if Item <> nil then Result := Result + Item.GetAbMoveTypesAll;
  end;
end;

function THeroItems.GetImmunityTypes: TDamageTypes;
var I: Integer; Item: TItem;
begin
  Result := [];
  for I := 0 to Count - 1 do
  begin
    Item := TItem(FChildren.List^[I]);
    if Item <> nil then Result := Result + Item.GetAbImmunityTypesAll;
  end;
end;

function THeroItems.GetProtectionTypes: TDamageTypes;
var I: Integer; Item: TItem;
begin
  Result := [];
  for I := 0 to Count - 1 do
  begin
    Item := TItem(FChildren.List^[I]);
    if Item <> nil then Result := Result + Item.GetAbProtectionTypesAll;
  end;
end;

function THeroItems.GetAbilityCount: Integer;
var I: Integer; Item: TItem;
begin
  Result := 0;
  for I := 0 to Count - 1 do
  begin
    Item := TItem(FChildren.List^[I]);
    if (Item <> nil) and (Result < Item.GetAbCount) then Result := Item.GetAbCount;
  end;
end;

function THeroItems.GetSuperlativeEnabledAbOwner(AbilityID: Integer): TAbilityOwner;
var I: Integer; Item: TItem;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    Item := TItem(FChildren.List^[I]);
    if (Item <> nil) and Item.GetAbEnabled(AbilityID) then
      if (Result = nil) or (Item.GetAbLevel(AbilityID) > Result.GetAbLevel(AbilityID)) then
        Result := Item;
  end;
end;

function THeroItems.GetSuperlativeAbOwner(AbilityID: Integer): TAbilityOwner;
var I: Integer; Item: TItem;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    Item := TItem(FChildren.List^[I]);
    if (Item <> nil) and Item.GetAbSet(AbilityID) then
      if (Result = nil) or (Item.GetAbLevel(AbilityID) > Result.GetAbLevel(AbilityID)) then
        Result := Item;
  end;
end;

function THeroItems.GetAbilityEnabled(AbilityID: Integer): Boolean;
var I: Integer; Item: TItem;
begin
  Result := False;
  I := 0;
  while not Result and (I < Count) do
  begin
    Item := TItem(FChildren.List^[I]);
    Result := (Item <> nil) and Item.GetAbEnabled(AbilityID);
    Inc(I);
  end;
end;

function THeroItems.GetAbilitySet(AbilityID: Integer): Boolean;
var I: Integer; Item: TItem;
begin
  Result := False;
  I := 0;
  while not Result and (I < Count) do
  begin
    Item := TItem(FChildren.List^[I]);
    Result := (Item <> nil) and Item.GetAbSet(AbilityID);
    Inc(I);
  end;
end;

function THeroItems.GetPositionItem(Position: THeroItemPosition): TItem;
var Index: Integer;
begin
  Index := Ord(Position) and $7F;
  if Index < FChildren.Count then Result := TItem(FChildren.List^[Index])
  else Result := nil;
end;

function THeroItems.GetPositionItemType(Position: THeroItemPosition): TItemType;
const Types: array[0..5] of TItemType = (itAttack, itHead, itDefense, itRing, itTorso, itRing);
begin
  Result := Types[Ord(Position)];
end;

function THeroItems.GetItemTypePosition(ItemType: TItemType): THeroItemPosition;
const Positions: array[TItemType] of THeroItemPosition =
  (ipHeadSlot, ipTorsoSlot, ipAttackSlot, ipDefenseSlot, ipLeftRingSlot, ipNone, ipNone);
begin
  Result := Positions[ItemType];
end;

function THeroItems.CanPlaceItem(Item: TItem; Position: THeroItemPosition): Boolean;
begin
  Result := (Item <> nil) and (Ord(Position) < 6) and
    (GetPositionItem(Position) = nil) and (GetPositionItemType(Position) = Item.FItemType);
end;

function THeroItems.PlaceItem(Item: TItem; Position: THeroItemPosition): Boolean;
begin
  if CanPlaceItem(Item, Position) then
  begin
    Item.SetArrayOwner(Self, Ord(Position));
    Result := True;
  end
  else Result := False;
end;

function THeroPowerSource.Name: string;
begin
  Result := FHero.FHeroName;
end;

function THeroPowerSource.Power: Integer;
begin
  Result := FHero.GetPowerGeneration;
end;

procedure THeroPowerSource.Select;
var
  X, Y, L: Shortint;
  ArmyHS: TArmyHS;
begin
  GetLocation(X, Y, L);
  if X <> -1 then
  begin
    ArmyHS := TAoWMapField(AoWHSMap.MapContainer.GetField(X, Y, L)).GetArmyHS;
    if ArmyHS <> nil then AoWHSMap.Select(ArmyHS, True);
  end;
end;

procedure THeroPowerSource.GetLocation(var A1, A2, A3: Shortint);
begin
  FHero.GetLocation(A1, A2, A3);
end;

constructor THero.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FHeroItems := THeroItems.Create(TECustomNode(Self));
  FInventory := THeroInventory.Create(TECustomNode(Self));
  FPowerSource := THeroPowerSource.Create(nil);
  FPowerSource.FHero := Self;
  FHeroResourceIndex := -1;
  FHeroStatus := [];
  FLevel := 1;
  FCastingSpellID := 0;
  FCastingMana := 0;
  FCastingProgress := 0;
  FLibraryID := -1;
end;

destructor THero.Destroy;
begin
  AddRef;
  AddRef;
  AddRef;
  AddRef; { Original repeats the reference increment four times. }
  if FRegistered and (AoWHSMap <> nil) then AoWHSMap.FHeroControl.UnRegisterHero(Self);
  inherited Destroy;
  FHeroItems.Free;
  FInventory.Free;
  FPowerSource.Free;
end;

function THero.GetCampaignTransferPoints: Integer;
begin
  Result := inherited GetCampaignTransferPoints;
  Result := Result div 2;
end;

function THero.GetLibraryName: string;
begin
  Result := FLibraryName;
  if Result = '' then Result := TranslateRStr(DefaultRStr);
end;

procedure THero.UpdateFromLibraryBegin;
begin FMode := FMode + [hmUpdatingFromLibrary]; end;

procedure THero.UpdateFromLibraryEnd;
begin FMode := FMode - [hmUpdatingFromLibrary]; end;

procedure THero.UpdateFromLibrary;
var Hero: THero; ID: Integer;
begin
  if FLibraryID <> -1 then
  begin
    Hero := AoWHSSet.FHeroLibraries.FindHero(FLibraryName, FLibraryID);
    if Hero <> nil then
    begin
      ID := FUnitID;
      FMode := FMode + [hmUpdatingFromLibrary];
      Assign(Hero, AoWEngine);
      FMode := FMode - [hmUpdatingFromLibrary];
      FUnitID := ID;
      Changed;
    end;
  end;
end;

function THero.GetUnitLevel: Shortint;
begin Result := FLevel; end;

procedure THero.SetOwner(AOwner: Engine.TECustomNode);
begin
  AddRef;
  inherited SetOwner(AOwner);
  if usActivated in FUnitStatus then Changed;
  Release;
end;

function THero.GetNickname: string;
begin Result := FNickname; end;

procedure THero.SetNickname(Value: string);
begin FNickname := Value; end;

function THero.GetAbilitySelectionTypes: TAbilitySelectionTypes;
begin Result := [astEditor]; end;

function THero.GetEngine: Engine.TEngine;
begin Result := AoWEngine; end;

function THero.GetLibraryHero: Boolean;
begin Result := FLibraryID <> -1; end;

function THero.ShowEx(X,Y: Integer; const SD: TSurfaceDesc; const Info: TP2UnitShowInfo): Integer;
begin
  Result := inherited ShowEx(X, Y, SD, Info);
  if uoRank in Info.Overlays then
  begin
    AoWEngine.FCombatFont.Color := $FFFFFF;
    AoWEngine.FCombatFont.SetTextCentered(X + 43, Y + 12, IntToStr(GetLevel), SD);
  end;
end;

procedure THero.Changed;
begin
  inherited Changed;
  if (AoWHSMap <> nil) and not (msDestroying in AoWHSMap.Status) then
    AoWHSMap.FHeroControl.HeroChanged(Self);
end;

class function THero.ClassID: Integer;
begin Result := $20230; end;

function THero.GetObtainValue: Integer;
begin Result := GetLevel * 50 + 75; end;

function THero.GetDescription: TStrings;
begin Result := nil; end;

function THero.GetGender: TUnitGender;
begin Result := FGender; end;

function THero.GetUnitType: TUnitType;
begin Result := utHumanoid; end;

procedure THero.NewDay;
begin
  inherited NewDay;
  if AoWHSMap.FDay = 1 then
  begin
    if ((AoWEngine.FCampaign = nil) or (AoWHSMap.FPlayers.GetPlayers(FPlayer) = nil) or
       (AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerType <> ptHuman)) and
       (not AoWHSMap.FLeadersFixed or not (Self is TLeader)) then
      FUsedSkillPoints := GetSkillPoints;
    UpdateSettings;
  end;
end;

function THero.UsedSkillPoints: Integer;
var I: Integer;
begin
  Result := FUnitAttack * 5 + FUnitDefense * 5 + FUnitDamage * 10 +
    FUnitResistance * 5 + FUnitHits * 5 + FUnitMoves * 2;
  for I := GetAbCount - 1 downto 0 do
    if GetAbSet(I) then
    begin
      Inc(Result, AoWHSSet.FAbilityControl.GetAbility(I).GetSkillPoints(Self));
      if FHeroResource.FAbilities.GetAbSet(I) then
        Dec(Result, AoWHSSet.FAbilityControl.GetAbility(I).GetSkillPoints(FHeroResource.FAbilities));
    end;
end;

function THero.CanJoin(Player: Shortint): Boolean;
var Race: TRace; APlayer: TPlayer;
begin
  if FRace = -1 then Result := False
  else
  begin
    APlayer := AoWHSMap.FPlayers.GetPlayers(Player);
    Race := AoWHSMap.FRaces.GetRace(FRace);
    Result := Race.GetPlayerRelation(Player) in [sPolite, sFriendly];
    if Result and ((FGroup = nil) or (FGroup.Behavior <> gbRefuge)) and
      (not GetAbilityEnabled(128) or (Player <> FDeathPlayer) or
       (FDeathDay + 2 < AoWHSMap.FPlayers.GetPlayers(Player).FDay)) then
      Result := (APlayer.FHeroes.Count < APlayer.GetHeroCountMax) and
        (GetLevel <= APlayer.GetHeroJoinLevelMax);
  end;
end;

function THero.EmergedToPlayer: Shortint;
var I: Integer;
begin
  I := AoWHSMap.FPlayers.Count;
  Result := -1;
  while (I <> 1) and (Result = -1) do
  begin
    Dec(I);
    if AoWHSMap.FPlayers.GetPlayers(I).FEmergingHeroID = FUnitID then Result := I;
  end;
end;

function THero.OfferToJoin(Player: Shortint): Boolean;
var APlayer: TPlayer; Chance, Seed: Integer;
begin
  if CanJoin(Player) then
  begin
  APlayer := AoWHSMap.FPlayers.GetPlayers(Player);
  if EmergedToPlayer = -1 then
  begin
    if (not GetAbilityEnabled(128) or (Player <> FDeathPlayer)) and
      ((FGroup = nil) or (FGroup.Behavior <> gbRefuge)) then
    begin
      Chance := APlayer.GetHeroJoinChance(GetLevel);
      Seed := RandSeed;
      RandSeed := (AoWHSMap.FInitialRandomSeed + AoWHSMap.FDay + FUnitID * 16) and $FF8;
      Result := Random(100) < Chance;
      RandSeed := Seed;
    end
    else Result := True;
  end
  else Result := Player = EmergedToPlayer;
  end
  else Result := False;
end;

function THero.GetRace: Shortint;
begin Result := FHeroResource.FRace; end;

function THero.GetName: string;
begin Result := FHeroName; end;

function THero.GetMoveTypes: TMoveTypes;
begin
  Result := inherited GetMoveTypes;
  Result := Result + FHeroItems.GetMoveTypes;
end;

function THero.GetImmunityTypes: TDamageTypes;
begin
  Result := inherited GetImmunityTypes;
  Result := Result + FHeroItems.GetImmunityTypes;
end;

function THero.GetProtectionTypes: TDamageTypes;
begin
  Result := inherited GetProtectionTypes;
  Result := Result + FHeroItems.GetProtectionTypes;
end;

function THero.GetMovePoints: Shortint;
begin Result := FMovePoints; end;

procedure THero.SetMovePoints(Value: Shortint);
begin
  if GetMoves < Value then Value := GetMoves;
  FMovePoints := Value;
end;

function THero.GetHitPoints: Shortint;
begin Result := FHitPoints; end;

procedure THero.SetHitPoints(Value: Shortint);
begin
  if GetHits < Value then Value := GetHits;
  if Value < 0 then Value := 0;
  FHitPoints := Value;
  UpdateDefensiveStrength;
end;

function THero.GetAlignment: TAlignment;
var Race: Shortint;
begin
  if GetAbilityEnabled(107) then Result := alPureEvil
  else
  begin
    Race := FRace;
    if AoWHSSet.FRaceResources.GetRaceResource(Race) <> nil then
      Result := AoWHSSet.FRaceResources.GetRaceResource(Race).GetAlignment
    else Result := FHeroResource.FAlignment;
  end;
end;

procedure THero.DropItemsOnMap(Map: TAoWHSMap; X, Y, L: Shortint);
var I: Integer; Position: THeroItemPosition;
begin
  for I := FInventory.Count - 1 downto 0 do
    if FInventory.GetItem(I) <> nil then FInventory.GetItem(I).PlaceOnMap(Map, X, Y, L);
  for Position := ipAttackSlot to ipRightRingSlot do
    if FHeroItems.GetPositionItem(Position) <> nil then
      FHeroItems.GetPositionItem(Position).PlaceOnMap(Map, X, Y, L);
end;

procedure THero.Killed;
var I: Integer; Position: THeroItemPosition;
begin
  for I := FInventory.Count - 1 downto 0 do
    if FInventory.GetItem(I) <> nil then
      ExecutePlaceItem(FInventory.GetItem(I).FItemID, ipGround);
  for Position := ipAttackSlot to ipRightRingSlot do
    if FHeroItems.GetPositionItem(Position) <> nil then
      ExecutePlaceItem(FHeroItems.GetPositionItem(Position).FItemID, ipGround);
  FDeathDay := AoWHSMap.FPlayers.GetPlayers(FPlayer).FDay;
  FDeathPlayer := FPlayer;
  inherited Killed;
  Include(FHeroStatus, hsDied);
  SetPlayer(-1);
  SetOwner(nil);
end;

procedure THero.Resurrect;
begin
  inherited Resurrect;
  FHeroStatus := FHeroStatus - [hsDied];
end;

procedure THero.Animate;
begin
  inherited Animate;
  FHeroStatus := FHeroStatus - [hsDied];
end;

function THero.CanActivate: Boolean;
var Hero: THero;
begin
  Result := inherited CanActivate;
  if Result and not FRegistered and (FUnitID <> -1) then
  begin
    Hero := AoWHSMap.FHeroControl.FindID(FUnitID);
    if (Hero = nil) or (Hero = Self) then Result := True
    else
    begin
      if (Hero.Owner = nil) and CompatibleHero(Hero) then Result := True
      else Result := False;
    end;
  end;
end;

function THero.GetUpkeep: Shortint;
begin Result := GetLevel * 2 + 5; end;

procedure THero.SetPlayer(Player: Shortint);
begin
  if Player <> FPlayer then
  begin
    if (FPlayer <> -1) and (FPlayer < AoWHSMap.FPlayers.Count) then
    begin
      AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.UnregisterPowerSource(FPowerSource);
      AoWHSMap.FPlayers.GetPlayers(FPlayer).FHeroes.RemoveChild(Self);
    end;
    inherited SetPlayer(Player);
    if FPlayer <> -1 then
    begin
      AoWHSMap.FPlayers.GetPlayers(FPlayer).FHeroes.AddChild(Self);
      AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.RegisterPowerSource(FPowerSource);
      AoWHSMap.FPlayers.GetPlayers(FPlayer).ResetBaseHeroJoinDay;
    end;
  end;
end;

function THero.CompatibleHero(Hero: THero): Boolean;
var GroupID, OtherGroupID: Integer;
begin
  GroupID := FGroupID;
  OtherGroupID := Hero.FGroupID;
  Hero.FGroupID := 0;
  FGroupID := 0;
  Result := Hero.Compare(Self, AoWEngine);
  Hero.FGroupID := OtherGroupID;
  FGroupID := GroupID;
end;

procedure THero.Activate;
var Hero: THero;
begin
  if FUnitID <> -1 then
  begin
    Hero := AoWHSMap.FHeroControl.FindID(FUnitID);
    if (Hero <> nil) and (Hero <> Self) and (Hero.Owner = nil) and CompatibleHero(Hero) then
      AoWHSMap.FHeroControl.UnRegisterHero(Hero);
  end;
  if msEditting in AoWHSMap.Status then FLevel := GetLevel;
  if FHeroResourceIndex = -1 then SetHeroResourceIndex(0);
  if (FPlayer > 0) and (AoWHSMap.FPlayers.GetPlayers(FPlayer) = nil) and (Owner = nil) then FPlayer := -1;
  if (Owner = nil) and (FGroupID <> 0) then FGroupID := 0;
  inherited Activate;
  if AoWHSMap <> nil then
  begin
    if not (hmSkipLibraryUpdate in FMode) and
       ((msEditting in AoWHSMap.Status) or (AoWHSMap.FDay = 0)) then UpdateFromLibrary;
    if not FRegistered then AoWHSMap.FHeroControl.RegisterHero(Self);
    if (FPlayer <> -1) and (Owner <> nil) then
    begin
      AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.RegisterPowerSource(FPowerSource);
      AoWHSMap.FPlayers.GetPlayers(FPlayer).FHeroes.AddChild(Self);
    end;
    FInventory.RegisterItems;
    FHeroItems.RegisterItems;
  end;
end;

procedure THero.Deactivate;
begin
  if (FPlayer <> -1) and (FPlayer < AoWHSMap.FPlayers.Count) then
  begin
    AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.UnregisterPowerSource(FPowerSource);
    AoWHSMap.FPlayers.GetPlayers(FPlayer).FHeroes.RemoveChild(Self);
  end;
  inherited Deactivate;
end;

function THero.GetUnitGFXResourceIndex: Integer;
begin Result := FHeroResource.FUnitGFXResourceIndex; end;

function THero.GetSkillPoints: Integer;
begin
  if (AoWHSMap <> nil) and not (msEditting in AoWHSMap.Status) then
    Result := FLevel * 10 + 15 - UsedSkillPoints - FUsedSkillPoints
  else Result := FLevel * 10 + 15 - UsedSkillPoints;
end;

function THero.GetSkillPointsMax: Integer;
begin Result := FLevel * 10 + 15 - FUsedSkillPoints; end;

function THero.GetLevelMax: Integer;
var Maximum: Integer;
begin
  Result := 30;
  if (AoWHSMap <> nil) and (AoWHSMap.FCampaignSettings <> nil) and
    (AoWHSMap.FCampaignSettings.FHeroLevelMax > 0) then
  begin
    Maximum := AoWHSMap.FCampaignSettings.FHeroLevelMax;
    if Result > Maximum then Result := Maximum;
  end;
end;

function THero.GetExperience: Integer;
begin Result := FExperience; end;

procedure THero.SetExperience(Value: Integer);
var Maximum: Integer;
begin
  FExperience := Value;
  Maximum := LevelToExperience(GetLevelMax);
  if Maximum < FExperience then FExperience := Maximum;
  Changed;
end;

function THero.LevelToExperience(Level: Integer): Integer;
var I, Total: Integer;
begin
  Total := 0;
  for I := 1 to Level - 1 do
    if I div 5 <= 5 then Inc(Total, P2HeroLevels[I div 5].Experience);
  Result := Total;
end;

function THero.ExperienceToLevel(Experience: Integer): Shortint;
var Level, Total, Maximum: Integer;
begin
  Level := 1;
  Total := 0;
  Maximum := GetLevelMax;
  repeat
    Inc(Total, P2HeroLevels[Level div 5].Experience);
    if Experience < Total then Break;
    Inc(Level);
  until Level >= Maximum;
  Result := Level;
end;

function THero.GetNextLevelExperience: Integer;
var Level: Integer;
begin
  Level := GetLevel;
  if GetLevelMax > Level then Result := LevelToExperience(Level + 1)
  else Result := LevelToExperience(Level);
end;

function THero.GetLevel: Shortint;
begin
  with Self do Result := ExperienceToLevel(FExperience);
end;

procedure THero.SetLevel(Value: Shortint);
var Maximum, Level, Points: Integer;
begin
  Maximum := GetLevelMax;
  if Value < 1 then Value := 1;
  if Maximum < Value then Value := Maximum;
  Level := GetLevel;
  if Level > Value then
  begin
    Points := GetSkillPoints;
    while (Points >= 10) and (Level <> Value) do
    begin
      Dec(Level);
      Dec(Points, 10);
    end;
    Value := Level;
  end;
  FExperience := LevelToExperience(Value);
  FLevel := Value;
end;

function THero.GetHeroType: THeroType;
begin Result := FHeroResource.FHeroType; end;

procedure THero.SetUnitAttack(Value: Shortint);
var Points: Integer;
begin
  if Value < 0 then Value := 0;
  if Value + FHeroResource.FAttack > 10 then Value := 10 - FHeroResource.FAttack;
  if Value > FUnitAttack then
  begin
    Points := GetSkillPoints;
    while (Points >= 5) and (Value <> FUnitAttack) do
    begin
      Inc(FUnitAttack);
      Dec(Points, 5);
    end;
  end
  else FUnitAttack := Value;
end;

procedure THero.SetUnitDefense(Value: Shortint);
var Points: Integer;
begin
  if Value < 0 then Value := 0;
  if Value + FHeroResource.FDefense > 10 then Value := 10 - FHeroResource.FDefense;
  if Value > FUnitDefense then
  begin
    Points := GetSkillPoints;
    while (Points >= 5) and (Value <> FUnitDefense) do
    begin
      Inc(FUnitDefense);
      Dec(Points, 5);
    end;
  end
  else FUnitDefense := Value;
end;

procedure THero.SetUnitDamage(Value: Shortint);
var Points: Integer;
begin
  if Value < 0 then Value := 0;
  if Value + FHeroResource.FDamage > 10 then Value := 10 - FHeroResource.FDamage;
  if Value > FUnitDamage then
  begin
    Points := GetSkillPoints;
    while (Points >= 10) and (Value <> FUnitDamage) do
    begin
      Inc(FUnitDamage);
      Dec(Points, 10);
    end;
  end
  else FUnitDamage := Value;
end;

procedure THero.SetUnitHits(Value: Shortint);
var Points: Integer;
begin
  if Value < 0 then Value := 0;
  if Value + FHeroResource.FHits > 30 then Value := 30 - FHeroResource.FHits;
  if Value > FUnitHits then
  begin
    Points := GetSkillPoints;
    while (Points >= 5) and (Value <> FUnitHits) do
    begin
      Inc(FUnitHits);
      Dec(Points, 5);
    end;
  end
  else FUnitHits := Value;
end;

procedure THero.SetUnitMoves(Value: Shortint);
var Points: Integer;
begin
  if Value < 0 then Value := 0;
  if Value + FHeroResource.FMoves > 50 then Value := 50 - FHeroResource.FMoves;
  if Value > FUnitMoves then
  begin
    Points := GetSkillPoints;
    while (Points >= 2) and (Value <> FUnitMoves) do
    begin
      Inc(FUnitMoves);
      Dec(Points, 2);
    end;
  end
  else FUnitMoves := Value;
end;

procedure THero.SetUnitResistance(Value: Shortint);
var Points: Integer;
begin
  if Value < 0 then Value := 0;
  if Value + FHeroResource.FResistance > 10 then Value := 10 - FHeroResource.FResistance;
  if Value > FUnitResistance then
  begin
    Points := GetSkillPoints;
    while (Points >= 5) and (Value <> FUnitResistance) do
    begin
      Inc(FUnitResistance);
      Dec(Points, 5);
    end;
  end
  else FUnitResistance := Value;
end;

procedure THero.LinkToResource;
begin
  FHeroResource := AoWHSSet.FHeroResources.GetHeroResource(FHeroResourceIndex);
end;

procedure THero.Loaded;
begin
  if FHeroResource <> nil then
  begin
    UpdateDefaultAbilities(FHeroResource.FAbilities);
    SetUnitAttack(FUnitAttack);
    SetUnitDefense(FUnitDefense);
    SetUnitResistance(FUnitResistance);
    SetUnitDamage(FUnitDamage);
    SetUnitHits(FUnitHits);
    SetUnitMoves(FUnitMoves);
  end;
end;

procedure THero.ListSpells(var List: TSpellList);
begin
  AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.ListSpells(List, [stCombat, stUnit, stGlobal]);
end;

procedure THero.ExecuteUpgradeHeroAI;
var
  Choices: TDoubleItemList;
  Points, Index: Integer;
  Choice: TDoubleItem;
begin
  Choices := TDoubleItemList.Create;
  repeat
    Choices.Clear;
    Points := GetSkillPoints;
    if (Points >= 5) and (FUnitAttack + FHeroResource.FAttack < 10) then Choices.AddAB(0, 10);
    if (Points >= 5) and (FUnitDefense + FHeroResource.FDefense < 10) then Choices.AddAB(1, 25);
    if (Points >= 5) and (FUnitResistance + FHeroResource.FResistance < 10) then Choices.AddAB(2, 10);
    if (Points >= 10) and (FUnitDamage + FHeroResource.FDamage < 10) then Choices.AddAB(3, 10);
    if (Points >= 5) and (FUnitHits + FHeroResource.FHits < 30) then Choices.AddAB(4, 10);
    if AoWHSSet.FAbilityControl.GetAbility(46).CanExpand(Self) and
      (Points >= AoWHSSet.FAbilityControl.GetAbility(46).ExpandCost(Self)) then Choices.AddAB(5, 10);
    if AoWHSSet.FAbilityControl.GetAbility(22).CanExpand(Self) and
      (Points >= AoWHSSet.FAbilityControl.GetAbility(22).ExpandCost(Self)) then Choices.AddAB(6, 10);
    if AoWHSSet.FAbilityControl.GetAbility(52).CanExpand(Self) then
      if Points >= AoWHSSet.FAbilityControl.GetAbility(52).ExpandCost(Self) then Choices.AddAB(7, 9999)
      else Choices.AddAB(7, 100);
    if Choices.Count <> 0 then
    begin
      RandSeed := AoWHSMap.Random($FFFFFF);
      Index := Choices.RandomChanceItemB(0);
      Choice := Choices[Index];
      case Choice.A of
        0: SetUnitAttack(FUnitAttack + 1);
        1: SetUnitDefense(FUnitDefense + 1);
        2: SetUnitResistance(FUnitResistance + 1);
        3: SetUnitDamage(FUnitDamage + 1);
        4: SetUnitHits(FUnitHits + 1);
        5: ExpandAbility(46);
        6: ExpandAbility(22);
        7: if Points >= AoWHSSet.FAbilityControl.GetAbility(52).ExpandCost(Self) then ExpandAbility(52)
           else Points := 0;
      end;
    end;
  until (Choices.Count = 0) or (GetSkillPoints = 0) or (Points = 0);
  Choices.Free;
end;

procedure THero.ValidateHeroUpgrade;
var
  X, Y, L: Shortint;
  Level, OldLevel: Integer;
  Log: THeroUpgradeEventLog;
begin
  GetLocation(X, Y, L);
  if (FPlayer <> 0) and (X <> -1) then
  begin
    FUpgradePending := False;
    Level := GetLevel;
    if Level < GetLevelMax then
    begin
      if (FPlayer > 0) and (AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerType = ptCPU2) then
        SetExperience(GetExperience + (P2HeroLevels[Level div 5].Experience + 1))
      else if (FPlayer > 0) and (AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerType = ptCPU3) then
        SetExperience(GetExperience + (P2HeroLevels[Level div 5].Experience + 2))
      else if (FPlayer > 0) and (AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerType = ptCPU4) then
        SetExperience(GetExperience + (P2HeroLevels[Level div 5].Experience + 3))
      else if (FPlayer > 0) and (AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerType = ptCPU5) then
        SetExperience(GetExperience + (P2HeroLevels[Level div 5].Experience + 4))
      else SetExperience(GetExperience + P2HeroLevels[Level div 5].Experience);
      Level := GetLevel;
    end;
    if FLevel < Level then
    begin
      FUpgradePending := True;
      OldLevel := FLevel;
      FLevel := Level;
      Log := THeroUpgradeEventLog.Create(nil);
      Log.FOldLevel := OldLevel;
      Log.FNewLevel := FLevel;
      Log.FDay := AoWHSMap.FPlayers.GetPlayers(FPlayer).FDay;
      Log.FPlayer := FPlayer;
      Log.FUnitID := FUnitID;
      DistributeLocationEventLog(Log, FPlayer, X, Y, L, True);
      Log.Release;
      if AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerType <> ptHuman then ExecuteUpgradeHeroAI;
    end;
  end;
end;

procedure THero.NewTurn(Player: Shortint);
var Log: TSpellCastEventLog;
begin
  inherited NewTurn(Player);
  if Player = FPlayer then
  begin
    ValidateHeroUpgrade;
    FCastingPoints := GetCastingPointsMax;
    if (FCastingSpellID <> 0) and (FCastingMana < FCastingProgress) then
    begin
      Inc(FCastingMana, FCastingPoints);
      FCastingPoints := 0;
      if FCastingMana > FCastingProgress then
      begin
        FCastingPoints := FCastingMana - FCastingProgress;
        FCastingMana := FCastingProgress;
      end;
      if FCastingMana = FCastingProgress then
      begin
        Log := TSpellCastEventLog.Create(nil);
        Log.FPlayer := FPlayer;
        Log.FUnitID := FUnitID;
        Log.FSpellID := FCastingSpellID;
        AoWHSMap.FPlayers.GetPlayers(FPlayer).FEventLogbook.AddEvent(Log);
        if (AoWHSMap.FSeatedPlayer = FPlayer) and
          (AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerType = ptHuman) then
          Log.Execute(False, etEvent, nil);
        Log.Release;
      end;
    end;
  end;
end;

procedure THero.SetAbSet(A1: Integer; A2: Byte);
begin inherited SetAbSet(A1, A2); end;

function THero.GetAbSet(A1: Integer): Boolean;
begin Result := inherited GetAbSet(A1); end;

function THero.GetUnitAbilityEnabled(AbilityID: Integer): Boolean;
begin Result := inherited GetAbilityEnabled(AbilityID); end;

function THero.GetAbilityCount: Integer;
var Count: Integer;
begin
  Result := GetAbCount;
  Count := FHeroItems.GetAbilityCount;
  if Count > Result then Result := Count;
  Count := FInventory.GetAbilityCount;
  if Count > Result then Result := Count;
end;

function THero.GetSuperlativeEnabledAbOwner(AbilityID: Integer): TAbilityOwner;
var Candidate, Best: TAbilityOwner;
begin
  if GetAbEnabled(AbilityID) then Best := Self else Best := nil;
  Candidate := FHeroItems.GetSuperlativeEnabledAbOwner(AbilityID);
  if Candidate <> nil then
    if (Best = nil) or (Candidate.GetAbLevel(AbilityID) > Best.GetAbLevel(AbilityID)) then
      Best := Candidate;
  Candidate := FInventory.GetSuperlativeEnabledAbOwner(AbilityID);
  if Candidate <> nil then
    if (Best = nil) or (Candidate.GetAbLevel(AbilityID) > Best.GetAbLevel(AbilityID)) then
      Best := Candidate;
  Result := Best;
end;

function THero.GetSuperlativeAbOwner(AbilityID: Integer): TAbilityOwner;
var Candidate, Best: TAbilityOwner;
begin
  if GetAbSet(AbilityID) then Best := Self else Best := nil;
  Candidate := FHeroItems.GetSuperlativeAbOwner(AbilityID);
  if Candidate <> nil then
    if (Best = nil) or (Candidate.GetAbLevel(AbilityID) > Best.GetAbLevel(AbilityID)) then
      Best := Candidate;
  Candidate := FInventory.GetSuperlativeAbOwner(AbilityID);
  if Candidate <> nil then
    if (Best = nil) or (Candidate.GetAbLevel(AbilityID) > Best.GetAbLevel(AbilityID)) then
      Best := Candidate;
  Result := Best;
end;

function THero.GetAbilityOwner(AbilityID: Integer): TAbilityOwner;
begin Result := GetSuperlativeAbOwner(AbilityID); end;

function THero.GetAbilityEnabled(AbilityID: Integer): Boolean;
begin
  Result := inherited GetAbilityEnabled(AbilityID);
  if not Result then Result := FHeroItems.GetAbilityEnabled(AbilityID);
  if not Result then Result := FInventory.GetAbilityEnabled(AbilityID);
end;

function THero.GetAbilitySet(AbilityID: Integer): Boolean;
begin
  Result := inherited GetAbilitySet(AbilityID);
  if not Result then Result := FHeroItems.GetAbilitySet(AbilityID);
  if not Result then Result := FInventory.GetAbilitySet(AbilityID);
end;

function THero.GetAbilityName(AbilityID: Integer): string;
var AOwner: TAbilityOwner;
begin
  AOwner := GetSuperlativeAbOwner(AbilityID);
  if AOwner = nil then AOwner := Self;
  Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).GetName(AOwner);
end;

function THero.GetAbilityLevel(AbilityID: Integer): Integer;
var AOwner: TAbilityOwner;
begin
  AOwner := GetSuperlativeAbOwner(AbilityID);
  if AOwner = nil then AOwner := Self;
  Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).GetLevel(AOwner);
end;

function THero.GetInherentAttack: Shortint;
begin Result := FHeroResource.FAttack + FUnitAttack; end;

function THero.GetAttack: Shortint;
var AOwner: TAbilityOwner; I, Count: Integer;
begin
  Count := GetAbilityCount;
  Result := 0;
  { Original includes the ability-count index in the scan. }
  for I := 0 to Count do
  begin
    AOwner := GetSuperlativeEnabledAbOwner(I);
    if AOwner <> nil then Inc(Result, AOwner.GetAbAttack(I));
  end;
  Result := FHeroItems.GetAttack + (FUnitAttack + Result + FHeroResource.FAttack);
  if Smallint(Result) < 1 then Result := 1;
  if Smallint(Result) > 10 then Result := 10;
end;

function THero.GetInherentDefense: Shortint;
begin Result := FHeroResource.FDefense + FUnitDefense; end;

function THero.GetDefense: Shortint;
var AOwner: TAbilityOwner; I, Count: Integer;
begin
  Count := GetAbilityCount;
  Result := 0;
  { Original includes the ability-count index in the scan. }
  for I := 0 to Count do
  begin
    AOwner := GetSuperlativeEnabledAbOwner(I);
    if AOwner <> nil then Inc(Result, AOwner.GetAbDefense(I));
  end;
  Result := FHeroItems.GetDefense + (FUnitDefense + Result + FHeroResource.FDefense) + P2MoraleDefense[GetMorale];
  if Smallint(Result) < 1 then Result := 1;
  if Smallint(Result) > 10 then Result := 10;
end;

function THero.GetInherentDamage: Shortint;
begin Result := FHeroResource.FDamage + FUnitDamage; end;

function THero.GetDamage: Shortint;
var AOwner: TAbilityOwner; I, Count: Integer;
begin
  Count := GetAbilityCount;
  Result := 0;
  { Original includes the ability-count index in the scan. }
  for I := 0 to Count do
  begin
    AOwner := GetSuperlativeEnabledAbOwner(I);
    if AOwner <> nil then Inc(Result, AOwner.GetAbDamage(I));
  end;
  Result := FHeroItems.GetDamage + (FUnitDamage + Result + FHeroResource.FDamage);
  if Smallint(Result) < 1 then Result := 1;
  if Smallint(Result) > 10 then Result := 10;
end;

function THero.GetInherentResistance: Shortint;
begin Result := FHeroResource.FResistance + FUnitResistance; end;

function THero.GetResistance: Shortint;
var AOwner: TAbilityOwner; I, Count: Integer;
begin
  Count := GetAbilityCount;
  Result := 0;
  { Original includes the ability-count index in the scan. }
  for I := 0 to Count do
  begin
    AOwner := GetSuperlativeEnabledAbOwner(I);
    if AOwner <> nil then Inc(Result, AOwner.GetAbResistance(I));
  end;
  Result := FHeroItems.GetResistance + (FUnitResistance + Result + FHeroResource.FResistance) + P2MoraleResistance[GetMorale];
  if Smallint(Result) < 1 then Result := 1;
  if Smallint(Result) > 10 then Result := 10;
end;

function THero.GetHits: Shortint;
begin
  Result := FHeroResource.FHits + FUnitHits;
  if Smallint(Result) < 1 then Result := 1;
  if Smallint(Result) > 30 then Result := 30;
end;

function THero.GetMoves: Shortint;
begin
  Result := FHeroResource.FMoves + FUnitMoves;
  if Smallint(Result) < 1 then Result := 1;
  if Smallint(Result) > 50 then Result := 50;
end;

function THero.GetPowerGeneration: Integer;
begin
  if GetAbilityEnabled(52) then Result := GetAbilityLevel(52) * 5
  else Result := 0;
end;

function THero.GetCastingPointsMax: Shortint;
begin
  if GetAbilityEnabled(52) then Result := GetAbilityLevel(52) * 10
  else Result := 0;
end;

function THero.GetCastingPoints: Shortint;
begin Result := FCastingPoints; end;

procedure THero.SetCastingPoints(Value: Shortint);
begin
  if Value > GetCastingPointsMax then Value := GetCastingPointsMax;
  FCastingPoints := Value;
  Changed;
end;

function THero.GetPreviewImage: TLibraryImage;
begin
  if FHeroResource <> nil then Result := FHeroResource.GetPreviewImage
  else Result := nil;
end;

procedure THero.ResetSkillPoints;
begin
  AssignAb(FHeroResource.FAbilities);
  FUnitAttack := 0;
  FUnitDefense := 0;
  FUnitDamage := 0;
  FUnitHits := 0;
  FUnitMoves := 0;
  FUnitResistance := 0;
end;

procedure THero.ResetResourceSettings;
begin
  AssignAb(FHeroResource.FAbilities);
  FUnitAttack := 0;
  FUnitDefense := 0;
  FUnitDamage := 0;
  FUnitHits := 0;
  FUnitMoves := 0;
  FUnitResistance := 0;
  FExperience := 0;
  FRace := FHeroResource.FRace;
  if (AoWHSMap <> nil) and (msEditting in AoWHSMap.Status) then FFaceIndex := FHeroResource.FFaceIndex;
  Changed;
end;

procedure THero.UpdateSettings;
begin
  FMovePoints := GetMoves;
  FHitPoints := GetHits;
  FCastingPoints := GetCastingPointsMax;
  FLevel := ExperienceToLevel(FExperience);
  Changed;
end;

procedure THero.SetRace(Value: Shortint);
var Found: Boolean; Index: Integer; Resource: THeroResource;
begin
  if FRace <> Value then
  begin
    Found := False;
    Index := AoWHSSet.FHeroResources.GetCount;
    while not Found and (Index <> 0) do
    begin
      Dec(Index);
      Resource := AoWHSSet.FHeroResources.GetHeroResource(Index);
      Found := (Resource <> nil) and (Resource.FRace = Value) and (GetHeroType = Resource.FHeroType);
    end;
    if Found then SetHeroResourceIndex(Index);
  end;
end;

function THero.GetFace: TLibraryImage;
var Resource: TFaceResource; Index: Integer;
begin
  if not GetAbilityEnabled(126) then
  begin
    Resource := AoWHSSet.FFaceResources.GetFaceResource(FFaceIndex);
    if Resource <> nil then Result := Resource.GetCellImage
    else Result := nil;
  end
  else
  begin
    Index := TCosmeticSurgeryEnchantment(TUnitEnchantmentAbilityData(GetAbilityData(126)).FEnchantment).FFaceIndex;
    Result := AoWHSSet.FFaceResources.GetFaceResource(Index).GetCellImage;
  end;
end;

procedure THero.SetFaceIndex(Value: Integer);
begin FFaceIndex := Value; end;

procedure THero.SetHeroResourceIndex(Value: Integer);
begin
  if (AoWHSSet.FHeroResources.GetHeroResource(Value) <> nil) and (Value <> FHeroResourceIndex) then
  begin
    FHeroResourceIndex := Value;
    FHeroResource := AoWHSSet.FHeroResources.GetHeroResource(Value);
    ResetResourceSettings;
  end;
end;

procedure THero.ReadWrite(Stream: Engine.TEStorageStream);
var Player: Shortint; OldExperience: Integer;
begin
  Player := FPlayer;
  Stream.rwInteger(FHeroResourceIndex, 8);
  if Stream.StorageMode * [smRead, smTextOnly, smSetupCompare, smCompare] = [smRead] then LinkToResource;
  inherited ReadWrite(Stream);
  if (Stream.StorageMode * [smRead, smTextOnly, smSetupCompare, smCompare] = [smRead]) and
    (hmUpdatingFromLibrary in FMode) then FPlayer := Player;
  Stream.rwInteger(FFaceIndex, 7);
  if Stream.StorageMode * [smRead, smTextOnly, smSetupCompare, smCompare] = [smRead] then
    Stream.rwInteger(OldExperience, 9)
  else OldExperience := 0;
  Stream.rwString(FHeroName, 10);
  Stream.rwString(FNickname, 11);
  Stream.rwByte(Byte(FRace), 12);
  Stream.rwByte(Byte(FCastingPoints), 13);
  Stream.rwInteger(FCastingSpellID, 14);
  Stream.rwData(FGender, 1, 15);
  Stream.rwByte(Byte(FUnitAttack), 16);
  Stream.rwByte(Byte(FUnitDefense), 17);
  Stream.rwByte(Byte(FUnitDamage), 18);
  Stream.rwByte(Byte(FUnitHits), 19);
  Stream.rwByte(Byte(FUnitMoves), 20);
  Stream.rwByte(Byte(FUnitResistance), 21);
  Stream.rwByte(FLevel, 22);
  Stream.rwBool(FUpgradePending, 23);
  Stream.rwInteger(FExperience, 24);
  Stream.rwData(FHeroStatus, 1, 25);
  Stream.rwInteger(FDeathDay, 26);
  Stream.rwByte(Byte(FDeathPlayer), 27);
  if (Stream.StorageMode * [smRead, smTextOnly, smCompare] = [smRead]) and (FExperience = 0) then
    FExperience := LevelToExperience((OldExperience shr 5) + 1);
  Stream.rwByte(Byte(FMovePoints), 29);
  Stream.rwByte(Byte(FHitPoints), 30);
  Stream.rwInteger(FCastingMana, 31);
  Stream.rwBool(FCastSpellInstantly, 33);
  Stream.rwInteger(FCastingProgress, 34);
  Stream.rwIntegerEx(FLibraryID, -1, 35);
  if not (hmUpdatingFromLibrary in FMode) then
  begin
    Stream.rwEObject(FInventory, 36);
    Stream.rwEObject(FHeroItems, 37);
  end;
  if not (smTextOnly in Stream.StorageMode) then Stream.rwString(FLibraryName, 38);
  Stream.rwInteger(FUsedSkillPoints, 39);
  if Stream.StorageMode * [smRead, smTextOnly, smSetupCompare, smCompare] = [smRead] then Loaded;
end;

procedure THero.EditDropMsg(var Msg: TEMsg);
var Level: TMapLevel; L, X, Y, Player: Integer; Placed: Boolean;
begin
  Level := TMapLevel(Msg.Param[0]);
  L := Msg.Data[1];
  HPtoHX(Msg.Value, Msg.Data[0], X, Y);
  if (X >= 0) and (Y >= 0) and (X < Level.Width) and (Y < Level.Height) then
  begin
    if msEditting in AoWHSMap.Status then
    begin
      Player := TAoWMapField(AoWHSMap.MapContainer.GetField(X, Y, L)).GetPlayer;
      if Player = -1 then Player := AoWHSMap.FEditorPlayer;
    end
    else Player := -1;
    Placed := Place(X, Y, L, Player, []) <> nil;
  end
  else Placed := False;
  if Placed then Msg.Result := 0 else Msg.Result := -1;
end;

procedure THero.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20020005 then
  begin
    if (AoWHSMap.FPlayers.GetCount <= FPlayer) and (Owner = nil) then
    begin
      SetPlayer(-1);
      Exit;
    end;
  end
  else if Msg.MsgID = $10005 then EditDropMsg(Msg);
end;

function THero.CreateHeroUpdateTE: THeroUpdateTE;
begin
  Result := THeroUpdateTE.Create(nil);
  Result.FUnitID := FUnitID;
end;

function THero.GetItemsOnGround: TItemList;
var Map: TAbstractAoWCombatMap;
begin
  Map := AoWHSMap.FCombatMap;
  if Map <> nil then Result := Map.GetHeroItemsOnGround(Self)
  else Result := AoWHSMap.GetHeroItemsOnGround(Self);
end;

function THero.CanUseItem(ItemID: Integer; var Reason: string): Boolean;
var Item: TItem;
begin
  Item := AoWHSMap.FItemControl.FindItem(ItemID);
  if Item <> nil then Result := Item.CanUse(Self, Reason)
  else
  begin
    Result := False;
    Reason := '';
  end;
end;

function THero.UseItem(ItemID: Integer): Boolean;
var Item: TItem;
begin
  Item := AoWHSMap.FItemControl.FindItem(ItemID);
  if Item <> nil then Result := Item.Use(Self)
  else Result := False;
end;

function THero.CanPlaceItem(ItemID: Integer; Position: THeroItemPosition): Boolean;
var Item: TItem; IX, IY, IL, X, Y, L: Shortint;
begin
  Result := False;
  Item := AoWHSMap.FItemControl.FindItem(ItemID);
  if Item <> nil then
  begin
    GetLocation(X, Y, L);
    Item.GetLocation(IX, IY, IL);
    if (AoWHSMap.FCombatMap <> nil) or ((X = IX) and (Y = IY) and (L = IL)) then
      if Position in [ipAttackSlot..ipRightRingSlot] then Result := FHeroItems.CanPlaceItem(Item, Position)
      else if Position in [ipInventorySlot1..ipInventorySlot8] then Result := FInventory.GetSlot(Position) = nil
      else Result := True;
  end;
end;

function THero.CanSwapItem(ItemID1, ItemID2: Integer): Boolean;
var Item1, Item2: TItem;
begin
  Result := True;
  Item1 := AoWHSMap.FItemControl.FindItem(ItemID1);
  Item2 := AoWHSMap.FItemControl.FindItem(ItemID2);
  if (Item1 <> nil) and (Item2 <> nil) and (Item1 <> Item2) then
  begin
    if (FHeroItems = Item1.Owner) or (FHeroItems = Item2.Owner) then
      Result := Item1.FItemType = Item2.FItemType;
  end
  else Result := False;
end;

function THero.SwapItem(ItemID1, ItemID2: Integer): Boolean;
var TE: THeroUpdateTE;
begin
  if CanSwapItem(ItemID1, ItemID2) and not AoWHSMap.FPlayers.GetPlayers(FPlayer).GetBusy then
  begin
    TE := CreateHeroUpdateTE;
    TE.FMode := hmSwapItem;
    TE.FItemID := ItemID1;
    TE.FParameter := ItemID2;
    AoWHSMap.FTokenManager.GetTokenControl(FPlayer).AddEvent(TE);
    TE.Release;
    Result := True;
  end
  else Result := False;
end;

function THero.PlaceItem(ItemID: Integer; Position: THeroItemPosition): Boolean;
var TE: THeroUpdateTE;
begin
  if CanPlaceItem(ItemID, Position) and not AoWHSMap.FPlayers.GetPlayers(FPlayer).GetBusy then
  begin
    TE := CreateHeroUpdateTE;
    TE.FMode := hmPlaceItem;
    TE.FItemID := ItemID;
    TE.FParameter := Ord(Position);
    AoWHSMap.FTokenManager.GetTokenControl(FPlayer).AddEvent(TE);
    TE.Release;
    Result := True;
  end
  else Result := False;
end;

function THero.ExecuteSwapItem(ItemID1, ItemID2: Integer): Boolean;
var Item1, Item2: TItem; Owner1, Owner2: TItemList; Index1, Index2: Integer;
begin
  if CanSwapItem(ItemID1, ItemID2) then
  begin
    Item1 := AoWHSMap.FItemControl.FindItem(ItemID1);
    Item2 := AoWHSMap.FItemControl.FindItem(ItemID2);
    Owner1 := TItemList(Item1.Owner);
    Owner2 := TItemList(Item2.Owner);
    Owner1.BeginUpdate;
    Owner2.BeginUpdate;
    Index1 := Item1.Owner.FindChildIndex(Item1);
    Index2 := Item2.Owner.FindChildIndex(Item2);
    Item1.SetOwner(nil);
    Item2.SetOwner(nil);
    if csArrayMode in Owner1.GetControlStyle then Item2.SetArrayOwner(Owner1, Index1)
    else Item2.SetOwner(Owner1);
    if csArrayMode in Owner2.GetControlStyle then Item1.SetArrayOwner(Owner2, Index2)
    else Item1.SetOwner(Owner2);
    Owner2.EndUpdate;
    Owner1.EndUpdate;
    Changed;
    Result := True;
  end
  else Result := False;
end;

function THero.AutoPlaceItem(Item: TItem): Boolean;
var Position: THeroItemPosition; Slot: Integer;
begin
  Result := False;
  Position := FHeroItems.GetItemTypePosition(Item.FItemType);
  if FHeroItems.CanPlaceItem(Item, Position) then
  begin
    FHeroItems.PlaceItem(Item, Position);
    Result := True;
  end
  else
  begin
    Slot := FInventory.GetFreeSlot;
    if Slot <> -1 then
    begin
      Item.SetArrayOwner(FInventory, Slot);
      Result := True;
    end;
  end;
end;

function THero.ExecutePlaceItem(ItemID: Integer; Position: THeroItemPosition): Boolean;
var Item: TItem; Map: TAbstractAoWCombatMap;
begin
  if CanPlaceItem(ItemID, Position) then
  begin
    Item := AoWHSMap.FItemControl.FindItem(ItemID);
    case Position of
      ipGround:
        begin
          Map := AoWHSMap.FCombatMap;
          if Map <> nil then Map.DropHeroItem(Self, Item)
          else AoWHSMap.DropHeroItem(Self, Item);
          Changed;
        end;
      ipAttackSlot..ipRightRingSlot:
        begin FHeroItems.PlaceItem(Item, Position); Changed; end;
      ipInventorySlot1..ipInventorySlot8:
        begin Item.SetArrayOwner(FInventory, Ord(Position) - 6); Changed; end;
    end;
    Result := True;
  end
  else Result := False;
end;

function THero.ExecuteStartCasting(SpellID: Integer): Boolean;
var Spell: TSpell;
begin
  if FCastingSpellID <> 0 then ExecuteCancelCasting;
  Spell := AoWHSSet.FSpellControl.GetSpell(SpellID);
  if (AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.FMana >= CastingMana(Spell)) and
    (CastingMana(Spell) > FCastingPoints) then
  begin
    FCastingProgress := CastingMana(Spell);
    AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.SetMana(
      AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.FMana - FCastingProgress);
    FCastingMana := FCastingPoints;
    FCastingPoints := 0;
    if AoWHSMap.FSeatedPlayer = FPlayer then
      AoWHSMap.ShowMessage(Format(TranslateRStr(CastingXInProgressRStr), [Spell.FSpellName]));
    FCastingSpellID := SpellID;
    Changed;
    Result := True;
  end
  else Result := False;
end;

procedure THero.RemoveCastingReadyEventLog;
var Logbook: TEventLogbook; I: Integer;
begin
  Logbook := AoWHSMap.FPlayers.GetPlayers(FPlayer).FEventLogbook;
  for I := Logbook.GetCount - 1 downto 0 do
    if (Logbook.GetLogs(I) is TSpellCastEventLog) and
      (TSpellCastEventLog(Logbook.GetLogs(I)).FUnitID = FUnitID) then Logbook.GetLogs(I).SetOwner(nil);
end;

function THero.ExecuteCancelCasting: Boolean;
begin
  if FCastingSpellID <> 0 then
  begin
    RemoveCastingReadyEventLog;
    if GetCastingPointsMax < FCastingPoints + FCastingMana then FCastingPoints := GetCastingPointsMax
    else Inc(FCastingPoints, FCastingMana);
    AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.SetMana(
      AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.FMana + FCastingProgress);
    FCastingSpellID := 0;
    FCastingMana := 0;
    FCastingProgress := 0;
    Changed;
    Result := True;
  end
  else Result := False;
end;

procedure THero.CastingDone(SpellID, Mana: Integer);
begin
  if SpellID = FCastingSpellID then
  begin
    Assert(CastingReady);
    FCastingMana := 0;
    FCastingProgress := 0;
    FCastingSpellID := 0;
    RemoveCastingReadyEventLog;
  end
  else
  begin
    if FCastingSpellID <> 0 then ExecuteCancelCasting;
    if not AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.GetCheatEnabled then
    begin
      AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.SetMana(
        AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.FMana - Mana);
      Dec(FCastingPoints, Mana);
    end;
  end;
end;

function THero.CastingMana(Spell: TSpell): Integer;
begin
  Result := Spell.FBaseManaCost;
  if AoWHSMap.FGlobalMagicControl.GetSphereManaDoubled(Spell.FMagicSphere) then Result := Result * 2;
end;

function THero.CastingTurns(Spell: TSpell): Integer;
var Mana, Points: Integer;
begin
  Mana := CastingMana(Spell);
  Points := FCastingPoints + FCastingMana;
  if Points > GetCastingPointsMax then Points := GetCastingPointsMax;
  if Mana > Points then
  begin
    Result := (Mana - Points) div GetCastingPointsMax;
    if (Mana - Points) mod GetCastingPointsMax <> 0 then Inc(Result);
  end
  else Result := 0;
end;

function THero.Casting: Boolean;
begin Result := FCastingSpellID <> 0; end;

function THero.CastingReady: Boolean;
begin Result := (FCastingSpellID <> 0) and (FCastingMana = FCastingProgress); end;

function THero.CastingTurnsLeft: Integer;
begin
  if (FCastingSpellID <> 0) and (GetCastingPointsMax <> 0) then
    if FCastingProgress > FCastingMana then
    begin
      Result := (FCastingProgress - FCastingMana) div GetCastingPointsMax;
      if (FCastingProgress - FCastingMana) mod GetCastingPointsMax <> 0 then Inc(Result);
    end
    else Result := 0
  else Result := -1;
end;

function THero.CanCastSpellInstantly(SpellID, Mana: Integer; var Reason: string): Boolean;
begin
  if not AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.GetCheatEnabled then
    if (Mana <= FCastingPoints) or ((SpellID = FCastingSpellID) and Casting and CastingReady) then
      Result := CanCastSpell(SpellID, Reason)
    else
    begin
      Result := False;
      Reason := TranslateRStr(P2NotEnoughCastingPointsRStr);
    end
  else Result := True;
end;

function THero.CanCastSpell(SpellID: Integer; var Reason: string): Boolean;
var Spell: TSpell;
begin
  if FCastingSpellID = 0 then
  begin
    Spell := AoWHSSet.FSpellControl.GetSpell(SpellID);
    if (AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.FMana >= CastingMana(Spell)) or
      AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.GetCheatEnabled then
      Result := Spell.CanActivate(Self, Reason)
    else
    begin
      Result := False;
      Reason := TranslateRStr(NotEnoughManaRStr);
    end;
  end
  else
  begin
    Result := SpellID = FCastingSpellID;
    if Result and (AoWHSSet.FSpellControl.GetSpell(SpellID).FSpellType = stGlobal) and
      (AoWHSMap.FCombatMap <> nil) then
    begin
      Reason := TranslateRStr(CannotCastSpellInCombatRStr);
      Result := False;
    end;
  end;
end;

function THero.CastSpell(SpellID: Integer; var Reason: string): Boolean;
var Spell: TSpell; TE: THeroUpdateTE;
begin
  if CanCastSpell(SpellID, Reason) then
  begin
    if FCastingSpellID = 0 then
    begin
      Spell := AoWHSSet.FSpellControl.GetSpell(SpellID);
      if (CastingMana(Spell) <= FCastingPoints) or
        AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.GetCheatEnabled then
      begin
        Result := Spell.CanActivate(Self, Reason);
        if Result then Result := Spell.Activate(Self);
      end
      else if not AoWHSMap.FPlayers.GetPlayers(FPlayer).GetBusy then
      begin
        if AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.FMana >= CastingMana(Spell) then
        begin
          TE := CreateHeroUpdateTE;
          TE.FMode := hmStartCasting;
          TE.FItemID := SpellID;
          AoWHSMap.FTokenManager.GetTokenControl(FPlayer).AddEvent(TE);
          TE.Release;
          Result := True;
        end
        else
        begin
          Result := False;
          Reason := TranslateRStr(NotEnoughManaRStr);
        end;
      end
      else Result := False;
    end
    else if CastingReady then
    begin
      Spell := AoWHSSet.FSpellControl.GetSpell(SpellID);
      Result := Spell.CanActivate(Self, Reason);
      if Result then Result := Spell.Activate(Self);
    end
    else Result := True;
  end
  else Result := False;
end;

function THero.CanCastCombatSpell(SpellID: Integer; var Reason: string): Boolean;
var Spell: TSpell;
begin
  if FCastingSpellID = 0 then
  begin
    Spell := AoWHSSet.FSpellControl.GetSpell(SpellID);
    if (CastingMana(Spell) <= FCastingPoints) or
      AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.GetCheatEnabled then
    begin
      if (AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.FMana >= CastingMana(Spell)) or
        AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.GetCheatEnabled then
        Result := Spell.CanActivateCombat(Self, Reason)
      else
      begin
        Result := False;
        Reason := TranslateRStr(NotEnoughManaRStr);
      end;
    end
    else
    begin
      Result := False;
      Reason := TranslateRStr(NotEnoughChannelingPointsRStr);
    end;
  end
  else
  begin
    Spell := AoWHSSet.FSpellControl.GetSpell(SpellID);
    Result := (Spell.FSpellType in [stCombat, stUnit]) and
      CanCastSpellInstantly(SpellID, CastingMana(Spell), Reason);
  end;
end;

function THero.CastCombatSpell(SpellID: Integer; var Reason: string): Boolean;
var Spell: TSpell;
begin
  Spell := AoWHSSet.FSpellControl.GetSpell(SpellID);
  if CanCastCombatSpell(SpellID, Reason) then
  begin
    Result := Spell.CanActivateCombat(Self, Reason);
    if Result then Result := Spell.ActivateCombat(Self);
  end
  else Result := False;
end;

function THero.CancelCasting: Boolean;
var TE: THeroUpdateTE;
begin
  { Original tests -1 although zero is the idle spell ID. }
  if (FCastingSpellID <> -1) and not AoWHSMap.FPlayers.GetPlayers(FPlayer).GetBusy then
  begin
    TE := CreateHeroUpdateTE;
    TE.FMode := hmCancelCasting;
    AoWHSMap.FTokenManager.GetTokenControl(FPlayer).AddEvent(TE);
    TE.Release;
    Result := True;
  end
  else Result := False;
end;

procedure THeroUpdateTE.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FUnitID, 20);
  Stream.rwData(FMode, 1, 21);
  Stream.rwInteger(FItemID, 22);
  Stream.rwInteger(FParameter, 23);
end;

class function THeroUpdateTE.ClassID: Integer;
begin Result := $21105; end;

function THeroUpdateTE.Execute(TE: TTokenExecuter): TExecuteResult;
var Success: Boolean; Hero: THero;
begin
  Success := False;
  Hero := THero(AoWHSMap.FUnitControl.FindUnit(FUnitID));
  if ((AoWHSMap.FCombat = nil) and (AoWHSMap.FCurrentPlayer = Hero.FPlayer)) or
    ((AoWHSMap.FCombat <> nil) and
    (AoWHSMap.FCombat.FCombatData.FPlayers.GetPlayers(AoWHSMap.FCombat.FCombatData.FCurrentPlayer).FPlayer = Hero.FPlayer)) then
    case FMode of
      hmPlaceItem: Success := Hero.ExecutePlaceItem(FItemID, THeroItemPosition(FParameter));
      hmSwapItem: Success := Hero.ExecuteSwapItem(FItemID, FParameter);
      hmStartCasting: Success := Hero.ExecuteStartCasting(FItemID);
      hmCancelCasting: Success := Hero.ExecuteCancelCasting;
    end;
  if Success then Result := erDone else Result := erDoneHalt;
end;

function THeroResourceAbilityOwner.GetAbilitySelectionTypes: TAbilitySelectionTypes;
begin Result := [astUnit, astEditor]; end;

constructor THeroResource.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FAbilities := THeroResourceAbilityOwner.Create(nil);
  FAttack := 3;
  FDefense := 3;
  FDamage := 3;
  FHits := 5;
  FMoves := 28;
  FResistance := 2;
end;

destructor THeroResource.Destroy;
begin FAbilities.Free; inherited Destroy; end;

class function THeroResource.ClassID: Integer;
begin Result := $20231; end;

function THeroResource.ResourceUserClassID: Integer;
begin Result := $20230; end;

function THeroResource.HeroResourceIndex: Integer;
begin Result := Owner.FindChildIndex(Self); end;

function THeroResource.UsedSkillPoints: Integer;
var I: Integer;
begin
  Result := FAttack * 5 + FDefense * 5 + FDamage * 10 + FResistance * 5 + FHits * 5 + FMoves * 2;
  for I := FAbilities.GetAbCount - 1 downto 0 do
    if FAbilities.GetAbSet(I) then
      Inc(Result, AoWHSSet.FAbilityControl.GetAbility(I).GetSkillPoints(FAbilities));
end;

procedure THeroResource.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwString(FName, 10);
  Stream.rwByte(Byte(FRace), 11);
  Stream.rwData(FHeroType, 1, 12);
  Stream.rwData(FAlignment, 1, 13);
  if FAlignment > alNone then FAlignment := alNeutral;
  Stream.rwBool(FHidden, 14);
  Stream.rwByte(Byte(FAttack), 15);
  Stream.rwByte(Byte(FDefense), 16);
  Stream.rwByte(Byte(FDamage), 17);
  Stream.rwByte(Byte(FHits), 18);
  Stream.rwByte(Byte(FMoves), 19);
  Stream.rwByte(Byte(FResistance), 20);
  Stream.rwEObject(FAbilities, 29);
  Stream.rwInteger(FFaceIndex, 30);
end;

constructor THeroResourceList.Create(AOwner: TECustomNode);
begin inherited Create(AOwner); SetControlStyle([csSaveLoad, csFixedChild, csArrayMode]); end;

function THeroResourceList.GetHeroResource(Index: Integer): THeroResource;
begin
  if (Index >= 0) and (Index < FChildren.Count) then Result := THeroResource(FChildren.List^[Index])
  else Result := nil;
end;

function THeroResourceList.CreateHeroResourceStrings(HeroTypes: THeroTypes): TStringList;
var I: Integer; Resource: THeroResource; List: TStringList;
begin
  List := TStringList.Create;
  for I := 0 to FChildren.Count - 1 do
  begin
    Resource := THeroResource(FChildren.List^[I]);
    if (Resource <> nil) and ((euDesigner in AoWEngine.FUser) or not Resource.FHidden) and
      (Resource.FHeroType in HeroTypes) then List.AddObject(Resource.FName, TObject(I));
  end;
  Result := List;
end;

function THeroResourceList.Find(Race: Integer; HeroType: THeroType): Integer;
var I: Integer; Resource: THeroResource;
begin
  I := 0;
  Result := -1;
  while (I < FChildren.Count) and (Result = -1) do
  begin
    Resource := THeroResource(FChildren.List^[I]);
    if (Resource <> nil) and (Race = Resource.FRace) and (HeroType = Resource.FHeroType) then Result := I;
    Inc(I);
  end;
end;

function THeroList.FindHero(ID: Integer): THero;
var I: Integer;
begin
  I := 0;
  Result := nil;
  while (I <> FChildren.Count) and (Result = nil) do
  begin
    if ID = THero(FChildren.List^[I]).FUnitID then Result := THero(FChildren.List^[I]);
    Inc(I);
  end;
end;

function THeroList.GetHero(Index: Integer): THero;
begin
  if (Index >= 0) and (Index < FChildren.Count) then Result := THero(FChildren.List^[Index])
  else Result := nil;
end;

constructor THeroControl.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FOnChanged := TEventList.Create;
  FOnHeroChanged := TEventList.Create;
  FHeroes := THeroList.Create(nil);
end;

destructor THeroControl.Destroy;
var I: Integer;
begin
  BeginUpdate;
  for I := FHeroes.GetCount - 1 downto 0 do UnRegisterHero(THero(FHeroes.FChildren.List^[I]));
  FHeroes.Free;
  FOnHeroChanged.Free;
  FOnChanged.Free;
  inherited Destroy;
end;

procedure THeroControl.Changed;
begin if FUpdateCount = 0 then FOnChanged.TriggerNotifyEvents(Self); end;

procedure THeroControl.ReadWrite(Stream: TEStorageStream);
var I: Integer;
begin
  inherited ReadWrite(Stream);
  Stream.rwEObject(FHeroes, 20);
  if Stream.StorageMode * [smRead, smTextOnly, smSetupCompare, smCompare] = [smRead] then
    for I := FHeroes.GetCount - 1 downto 0 do FHeroes.GetHero(I).FRegistered := True;
end;

procedure THeroControl.BeginUpdate;
begin Inc(FUpdateCount); end;

procedure THeroControl.EndUpdate;
begin Dec(FUpdateCount); if FUpdateCount = 0 then Changed; end;

procedure THeroControl.UpdateLibraryHeroes;
var I: Integer;
begin
  BeginUpdate;
  for I := FHeroes.GetCount - 1 downto 0 do THero(FHeroes.FChildren.List^[I]).UpdateFromLibrary;
  EndUpdate;
end;

function THeroControl.GetHero(Index: Integer): THero;
begin Result := THero(FHeroes.FChildren.List^[Index]); end;

function THeroControl.GetCount: Integer;
begin Result := FHeroes.GetCount; end;

function THeroControl.FindID(ID: Integer): THero;
begin Result := FHeroes.FindHero(ID); end;

function THeroControl.IndexOf(Hero: THero): Integer;
begin Result := FHeroes.FChildren.IndexOf(Hero); end;

function THeroControl.IndexOfLibraryEx(const LibraryName: string; LibraryID: Integer): Integer;
var Hero: THero;
begin
  Result := FHeroes.GetCount;
  while Result <> 0 do
  begin
    Dec(Result);
    Hero := THero(FHeroes.FChildren.List^[Result]);
    if (Hero.FLibraryID = LibraryID) and (CompareText(Hero.GetLibraryName, LibraryName) = 0) then Exit;
  end;
  Result := -1;
end;

procedure THeroControl.ValidateLibraryHeroes;
var I: Integer; Hero: THero;
begin
  for I := FHeroes.GetCount - 1 downto 0 do
  begin
    Hero := THero(FHeroes.FChildren.List^[I]);
    if (Hero <> nil) and (Hero.FLibraryID <> -1) and
      (AoWHSSet.FHeroLibraries.FindHero(Hero.FLibraryName, Hero.FLibraryID) = nil) then
      if Hero.Owner = nil then Hero.Free else Hero.FLibraryID := -1;
  end;
end;

procedure THeroControl.Activate;
var I: Integer; Hero: THero;
begin
  for I := FHeroes.GetCount - 1 downto 0 do
  begin
    Hero := THero(FHeroes.FChildren.List^[I]);
    if (not (usActivated in Hero.FUnitStatus)) and (Hero.Owner = nil) then Hero.Activate;
  end;
end;

procedure THeroControl.Deactivate;
var I: Integer; Hero: THero;
begin
  for I := FHeroes.GetCount - 1 downto 0 do
  begin
    Hero := THero(FHeroes.FChildren.List^[I]);
    if (usActivated in Hero.FUnitStatus) and (Hero.Owner = nil) then Hero.Deactivate;
  end;
end;

function THeroControl.RegisterHero(Hero: THero): Boolean;
begin
  if not Hero.FRegistered then
  begin Hero.FRegistered := True; FHeroes.AddChild(Hero); Changed; Result := True; end
  else Result := False;
end;

procedure THeroControl.UnRegisterHero(Hero: THero);
begin
  if Hero.FRegistered then
  begin Hero.FRegistered := False; FHeroes.RemoveChild(Hero); Changed; end;
end;

procedure THeroControl.HeroChanged(Hero: THero);
begin if not (msDestroying in AoWHSMap.Status) then FOnHeroChanged.TriggerNotifyEvents(Hero); end;

function THeroControl.GetAverageFreeHeroLevel: Integer;
var I, Count: Integer; Hero: THero;
begin
  Result := 0;
  Count := 0;
  for I := FHeroes.FChildren.Count - 1 downto 0 do
  begin
    Hero := THero(FHeroes.FChildren.List^[I]);
    if not (hsDied in Hero.FHeroStatus) and (Hero.FPlayer <= 0) then
    begin Inc(Result, Hero.GetLevel); Inc(Count); end;
  end;
  if Count <> 0 then Result := Result div Count else Result := 0;
end;

function THeroControl.GetMinFreeHeroLevel: Integer;
var I: Integer; Hero: THero;
begin
  Result := 30;
  for I := FHeroes.FChildren.Count - 1 downto 0 do
  begin
    Hero := THero(FHeroes.FChildren.List^[I]);
    if not (hsDied in Hero.FHeroStatus) and (Hero.FPlayer <= 0) and (Result > Hero.GetLevel) then
      Result := Hero.GetLevel;
  end;
end;

procedure THeroControl.ListDeadHeroes(List: THeroList);
var I: Integer; Hero: THero;
begin
  for I := FHeroes.FChildren.Count - 1 downto 0 do
  begin
    Hero := THero(FHeroes.FChildren.List^[I]);
    if hsDied in Hero.FHeroStatus then List.AddChild(Hero);
  end;
end;

procedure THeroControl.MsgProc(var Msg: TEMsg; Sender: TEObject);
var I: Integer;
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20000008 then
  begin ValidateLibraryHeroes; Activate; end
  else if Msg.MsgID = $20010017 then Deactivate
  else
    for I := FHeroes.GetCount - 1 downto 0 do
      if THero(FHeroes.FChildren.List^[I]).Owner = nil then
        THero(FHeroes.FChildren.List^[I]).MsgProc(Msg, Sender);
end;

function THeroLibrary.CreateUniqueLibraryID: Integer;
var I: Integer;
begin
  repeat
    I := 0;
    Inc(FNextLibraryID);
    if FNextLibraryID > $FFFFFFF then FNextLibraryID := 0;
    while (I <> FChildren.Count) and (THero(FChildren.List^[I]).FLibraryID <> FNextLibraryID) do Inc(I);
  until I = FChildren.Count;
  Result := FNextLibraryID;
end;

function THeroLibrary.AddChild(Child: TEObject): Integer;
begin
  with THero(Child) do
    { Original checks unit IDs rather than library IDs for a collision. }
    if (FLibraryID = 0) or (FindHero(FLibraryID) <> nil) then FLibraryID := CreateUniqueLibraryID;
  FChildren.Add(Child);
  if Child.AddRef = -1 then raise Exception.Create('EObject doesn''t support ReferenceCounting');
  Result := FChildren.Count - 1;
end;

function THeroLibrary.CreateHero: THero;
var Hero: THero;
begin
  Hero := THero.Create(nil);
  Hero.SetHeroResourceIndex(0);
  Hero.FLibraryID := CreateUniqueLibraryID;
  Hero.FLibraryName := FLibraryName;
  Hero.SetOwner(Self);
  Hero.Release;
  Result := Hero;
end;

function THeroLibrary.GetName: string;
begin
  Result := FLibraryName;
  if Result = '' then Result := TranslateRStr(SystemRStr);
end;

function THeroLibrary.FindLibraryID(ID: Integer): THero;
var I: Integer;
begin
  I := FChildren.Count;
  while I <> 0 do
  begin
    Dec(I);
    if ID = THero(FChildren.List^[I]).FLibraryID then
    begin Result := THero(FChildren.List^[I]); Exit; end;
  end;
  Result := nil;
end;

procedure THeroLibrary.LoadFromFile(const FileName: string);
begin AoWEngine.ReadFromFile(FileName, Self, nil); end;

procedure THeroLibrary.SaveToFile(const FileName: string);
begin AoWEngine.WriteToFile(FileName, Self, nil); end;

procedure THeroLibrary.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwString(FLibraryName, 20);
  Stream.rwInteger(FNextLibraryID, 21);
end;

constructor THeroLibraryManager.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FSystemLibrary := THeroLibrary.Create(nil);
  FLibraries := TENode.Create(nil);
end;

destructor THeroLibraryManager.Destroy;
begin FLibraries.Free; FSystemLibrary.Free; inherited Destroy; end;

procedure THeroLibraryManager.ReadWrite(Stream: TEStorageStream);
var Directory: string;
begin
  inherited ReadWrite(Stream);
  if Stream.StorageMode * [smTextOnly, smCompare] = [] then
  begin
    Directory := ExtractFilePath(AoWEngine.HSSFileName);
    if smRead in Stream.StorageMode then
    begin
      ReadUserLibraries;
      AoWEngine.ReadFromFile(Directory + 'Heroes.PFS', FSystemLibrary, nil);
    end
    else
    begin
      AoWEngine.WriteToFile(Directory + 'Heroes.PFS', FSystemLibrary, nil);
      WriteUserLibraries;
    end;
  end
  else Stream.rwEObject(FSystemLibrary, 20);
end;

function THeroLibraryManager.GetLibrary(Index: Integer): THeroLibrary;
begin Result := THeroLibrary(FLibraries.FChildren.EObjects[Index]); end;

function THeroLibraryManager.GetCount: Integer;
begin Result := FLibraries.GetCount; end;

procedure THeroLibraryManager.ReadUserLibraries;
var Lib: THeroLibrary; Search: TSearchRec; Found: Boolean;
begin
  FLibraries.Clear;
  FLibraries.AddChild(FSystemLibrary);
  Found := FindFirst(AoWEngine.StartupDirectory + 'User\' + '*' + '.ahl', faAnyFile - faDirectory, Search) = 0;
  while Found do
  begin
    Lib := THeroLibrary.Create(nil);
    try
      Lib.LoadFromFile(AoWEngine.StartupDirectory + 'User\' + Search.Name);
      Lib.SetOwner(FLibraries);
    except
      Lib.Free;
    end;
    Found := FindNext(Search) = 0;
  end;
  FindClose(Search);
end;

procedure THeroLibraryManager.WriteUserLibraries;
var I: Integer; Lib: THeroLibrary;
begin
  for I := 1 to FLibraries.GetCount - 1 do
  begin
    Lib := GetLibrary(I);
    Lib.SaveToFile(AoWEngine.StartupDirectory + 'User\' + Lib.GetName + '.ahl');
  end;
end;

function THeroLibraryManager.IndexOfLibraryName(const Name: string): Integer;
begin
  Result := FLibraries.GetCount;
  while Result <> 0 do
  begin
    Dec(Result);
    if CompareText(Name, THeroLibrary(FLibraries.FChildren.List^[Result]).FLibraryName) = 0 then Exit;
  end;
  Result := -1;
end;

function THeroLibraryManager.IndexOfLibrary(Lib: THeroLibrary): Integer;
begin Result := FLibraries.FChildren.IndexOf(Lib); end;

function THeroLibraryManager.FindHero(const LibraryName: string; LibraryID: Integer): THero;
var Index: Integer;
begin
  Index := IndexOfLibraryName(LibraryName);
  if Index <> -1 then Result := THeroLibrary(FLibraries.FChildren.List^[Index]).FindLibraryID(LibraryID)
  else Result := nil;
end;

function THeroLibraryManager.CreateLibrary(const Name: string): THeroLibrary;
var LibraryName: string;
begin
  LibraryName := Name;
  { Original retains the period when stripping the extension. }
  if Pos('.', LibraryName) <> 0 then LibraryName := System.Copy(LibraryName, 1, Pos('.', LibraryName));
  if (LibraryName <> '') and (IndexOfLibraryName(LibraryName) = -1) then
  begin
    Result := THeroLibrary.Create(FLibraries);
    Result.FLibraryName := LibraryName;
    Result.SaveToFile(AoWEngine.StartupDirectory + 'Release\' + LibraryName + '.ahl');
  end
  else Result := nil;
end;

procedure THeroLibraryManager.DeleteLibrary(Index: Integer);
begin
  if (Index < FLibraries.GetCount) and (Index > 0) then
  begin
    Windows.DeleteFile(PChar(AoWEngine.StartupDirectory + 'User\' + GetLibrary(Index).GetName + '.ahl'));
    GetLibrary(Index).Free;
  end;
end;

constructor TLeader.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FSpheres := TByteList.Create;
  FSpherePicksMax := 5;
end;

destructor TLeader.Destroy;
begin
  if (AoWHSMap <> nil) and (AoWHSMap.FPlayers.GetPlayers(FPlayer) <> nil) and
    (Self = AoWHSMap.FPlayers.GetPlayers(FPlayer).FLeader) then AoWHSMap.FPlayers.GetPlayers(FPlayer).SetLeader(nil);
  inherited Destroy;
  FSpheres.Free;
end;

procedure TLeader.Changed;
begin
  inherited Changed;
  if (AoWHSMap <> nil) and not (msDestroying in AoWHSMap.Status) then
    AoWHSMap.FOnLeaderChanged.TriggerNotifyEvents(Self);
end;

class function TLeader.ClassID: Integer;
begin Result := $20232; end;

function TLeader.GetUnitMoraleValue(Player, IndependentRelation: Shortint): Integer;
begin Result := 90; end;

function TLeader.GetNickname: string;
begin
  if AoWHSMap <> nil then
    if AoWHSMap.FGameType <> gtCampaign then Result := ''
    else begin Result := FNickname; Exit; end
  else Result := '';
end;

procedure TLeader.SetNickname(Value: string);
begin
  if (AoWHSMap <> nil) and (AoWHSMap.FGameType = gtCampaign) then inherited SetNickname(Value);
end;

function TLeader.GetSpherePicks(Sphere: TMagicSphere): Byte;
var I: Integer;
begin
  if Sphere <> msCosmos then
  begin
    Result := 0;
    for I := FSpheres.Count - 1 downto 0 do
      if FSpheres.List^[I] = Byte(Sphere) then Inc(Result);
  end
  else Result := 4;
end;

function TLeader.GetSpheres(Index: Integer): TMagicSphere;
begin Result := TMagicSphere(FSpheres.List^[Index]); end;

function TLeader.GetSphereCount: Integer;
begin Result := FSpheres.Count; end;

procedure TLeader.SetSpherePicksMax(Value: Byte);
begin
  FSpherePicksMax := Value;
  while FSpheres.Count > FSpherePicksMax do FSpheres.Delete(FSpheres.Count - 1);
end;

function TLeader.CanAddSphere(Sphere: TMagicSphere): Boolean;
begin
  if FSpheres.Count < FSpherePicksMax then
  begin
    if Sphere = msCosmos then begin Result := False; Exit; end;
    if AoWEngine.FDemo and (GetSpherePicks(Sphere) >= 2) then begin Result := False; Exit; end;
    if GetSpherePicks(Sphere) = 4 then begin Result := False; Exit; end;
    if (Sphere = msFire) and (GetSpherePicks(msWater) <> 0) then begin Result := False; Exit; end;
    if (Sphere = msWater) and (GetSpherePicks(msFire) <> 0) then begin Result := False; Exit; end;
    if (Sphere = msLife) and (GetSpherePicks(msDeath) <> 0) then begin Result := False; Exit; end;
    if (Sphere = msDeath) and (GetSpherePicks(msLife) <> 0) then begin Result := False; Exit; end;
    if (Sphere = msEarth) and (GetSpherePicks(msAir) <> 0) then begin Result := False; Exit; end;
    if (Sphere = msAir) and (GetSpherePicks(msEarth) <> 0) then begin Result := False; Exit; end;
    Result := True;
  end
  else Result := False;
end;

function TLeader.AddSphere(Sphere: TMagicSphere): Boolean;
begin Result := CanAddSphere(Sphere); if Result then FSpheres.Add(Byte(Sphere)); end;

procedure TLeader.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20020005 then
  begin
    SetSpherePicksMax(Byte(AoWHSMap.FSphereCount));
    if AoWHSMap.FPlayers.GetCount > FPlayer then
    begin
      if AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerRace <> FRace then
      begin
        SetHeroResourceIndex(AoWHSSet.FHeroResources.Find(AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerRace, htHeroLeader));
        Changed;
      end;
    end
    else Destroy;
  end;
end;

function TLeader.DeleteSphereIndex(Index: Integer): Boolean;
begin
  if (Index >= 0) and (Index < FSpheres.Count) then
  begin FSpheres.Delete(Index); Result := True; end
  else Result := False;
end;

function TLeader.DeleteSphere(Sphere: TMagicSphere): Boolean;
var I: Integer;
begin
  I := FSpheres.Count;
  Result := False;
  while not Result and (I <> 0) do
  begin
    Dec(I);
    Result := FSpheres[I] = Byte(Sphere);
  end;
  if Result then FSpheres.Delete(I);
end;

procedure TLeader.ClearSpheres;
begin FSpheres.Clear; end;

function TLeader.GetPowerGeneration: Integer;
begin
  if GetAbilityEnabled(52) then Result := GetAbilityLevel(52) * 5 + 5 else Result := 0;
end;

procedure TLeader.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByteEx(FSpherePicksMax, 5, 45);
  Stream.rwStreamProc(46, FSpheres.LoadFromStream, FSpheres.SaveToStream);
end;

function TLeader.GetEngine: TEngine;
begin Result := AoWEngine; end;

procedure TLeader.SetHeroResourceIndex(Value: Integer);
begin
  inherited SetHeroResourceIndex(Value);
  if (FHeroResource <> nil) and (AoWHSMap <> nil) and (msEditting in AoWHSMap.Status) then
    FHeroName := FHeroResource.FName;
end;

procedure TLeader.SetPlayer(Player: Shortint);
begin
  if Player <> FPlayer then
    if FPlayer <> 0 then begin SetOwner(nil); Changed; end
    else inherited SetPlayer(Player);
end;

procedure TLeader.Killed;
begin
  if (usActivated in FUnitStatus) and (AoWHSMap.FCombat = nil) then AoWHSMap.GameOver(FPlayer, goLost);
  inherited Killed;
end;

function TLeader.CanActivate: Boolean;
var Leader: TLeader;
begin
  Result := inherited CanActivate;
  if Result then
  begin
    Leader := AoWHSMap.FPlayers.GetPlayers(FPlayer).FLeader;
    if (Leader <> nil) and not CompatibleHero(Leader) then Result := False;
  end;
end;

procedure TLeader.Activate;
var Leader: TLeader;
begin
  FLibraryID := -1;
  if FPlayer = 0 then FPlayer := AoWHSMap.FPlayers.RaceToPlayer(FRace);
  inherited Activate;
  if AoWHSMap.FPlayers.GetPlayers(FPlayer) <> nil then
  begin
    Leader := AoWHSMap.FPlayers.GetPlayers(FPlayer).FLeader;
    if Leader <> Self then
    begin
      if (Leader <> nil) and (Leader.Owner <> nil) then
        try
          raise Exception.Create('Double leader used');
        except
          { Original silently swallows this duplicate-leader exception. }
        end;
      AoWHSMap.FPlayers.GetPlayers(FPlayer).SetLeader(Self);
      Changed;
    end
    else Changed;
  end
  else begin SetOwner(nil); Release; end;
end;

procedure TLeader.Deactivate;
begin inherited Deactivate; end;

procedure TLeader.EditDropMsg(var Msg: TEMsg);
var Level: TMapLevel; L, X, Y: Integer; Placed: Boolean;
begin
  Level := TMapLevel(Msg.Param[0]);
  L := Msg.Data[1];
  HPtoHX(Msg.Value, Msg.Data[0], X, Y);
  if (X >= 0) and (Y >= 0) and (X < Level.Width) and (Y < Level.Height) then
    Placed := Place(X, Y, L, FPlayer, []) <> nil
  else Placed := False;
  if Placed then Msg.Result := 0 else Msg.Result := -1;
end;

function TLeader.CanDisband(var Reason: string): Boolean;
begin Result := False; end;

function TLeader.GetUpkeep: Shortint;
begin Result := 0; end;

constructor TArmyID.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FUnitIDs := TIntegerList.Create;
end;

destructor TArmyID.Destroy;
begin
  FUnitIDs.Free;
  inherited Destroy;
end;

class function TArmyID.ClassID: Integer;
begin Result := $20220; end;

procedure TArmyID.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FPlayer), 10);
  Stream.rwInteger(Integer(Pointer(@FX)^), 11);
  Stream.rwStreamProc(12, FUnitIDs.LoadFromStream, FUnitIDs.SaveToStream);
end;

function TArmyID.Valid: Boolean;
var ArmyHS: TArmyHS; I: Integer;
begin
  if FX <> -1 then
  begin
    ArmyHS := TAoWMapField(AoWHSMap.MapContainer.GetField(FX, FY, FL)).GetArmyHS;
    if (ArmyHS <> nil) and (ArmyHS.FArmy.FPlayer = FPlayer) then
    begin
      I := FUnitIDs.Count;
      Result := True;
      while Result and (I <> 0) do
      begin
        Dec(I);
        Result := ArmyHS.FArmy.IndexOfID(FUnitIDs[I]) <> -1;
      end;
    end
    else Result := False;
  end
  else Result := False;
end;

function TArmyID.RetrieveArmy(var ArmyHS: TArmyHS; var Selection: Byte): Boolean;
var I, Index: Integer;
begin
  if FX <> -1 then
  begin
    Selection := 0;
    ArmyHS := TAoWMapField(AoWHSMap.MapContainer.GetField(FX, FY, FL)).GetArmyHS;
    if (ArmyHS <> nil) and (ArmyHS.FArmy.FPlayer = FPlayer) then
    begin
      I := FUnitIDs.Count;
      Result := True;
      while Result and (I <> 0) do
      begin
        Dec(I);
        Index := ArmyHS.FArmy.IndexOfID(FUnitIDs[I]);
        { Original shifts by the missing unit index before reporting failure. }
        Selection := Selection or (Byte(1) shl Index);
        Result := Index <> -1;
      end;
    end
    else Result := False;
  end
  else Result := False;
  if not Result then
  begin
    ArmyHS := nil;
    Selection := 0;
  end;
end;

class function TArmyView.ClassID: Integer;
begin Result := $20219; end;

function TArmyView.GetConcealedForPlayer(Player: Shortint): Boolean;
begin Result := (FConcealedForPlayers shr (Player - 1)) and 1 <> 0; end;

procedure TArmyView.SetConcealedForPlayer(Player: Shortint; Value: Boolean);
var Mask: Integer;
begin
  Mask := 1 shl (Player - 1);
  if Value then FConcealedForPlayers := FConcealedForPlayers or Word(Mask)
  else FConcealedForPlayers := FConcealedForPlayers and not Word(Mask);
end;

function TArmyView.GetUnitConcealedForPlayer(Index: Integer; Player: Shortint): Boolean;
begin Result := (FUnitConcealment[Index] shr (Player - 1)) and 1 <> 0; end;

procedure TArmyView.SetUnitConcealedForPlayer(Index: Integer; Player: Shortint; Value: Boolean);
var Mask: Integer;
begin
  Mask := 1 shl (Player - 1);
  if Value then FUnitConcealment[Index] := FUnitConcealment[Index] or Word(Mask)
  else FUnitConcealment[Index] := FUnitConcealment[Index] and not Word(Mask);
end;

procedure TArmyView.Setup(Army: TArmy; Selection: Byte);
var I, Player: Integer; AUnit: TAbstractUnit;
begin
  AssignSettings(Army);
  FX := Army.FX;
  FY := Army.FY;
  FL := Army.FL;
  for I := 0 to Army.GetCount - 1 do
  begin
    if Selection and 1 <> 0 then
    begin
      AUnit := TAbstractUnit(Army.GetUnit(I).Copy(AoWEngine));
      AUnit.SetOwner(Self);
      AUnit.Release;
      FMoraleValues[GetCount - 1] := Army.GetUnit(I).FMoraleValue;
      for Player := 1 to AoWHSMap.FPlayers.GetCount - 1 do
        SetUnitConcealedForPlayer(GetCount - 1, Player, Army.GetUnitConcealedForPlayer(I, Player));
    end;
    Selection := Selection shr 1;
  end;
end;

procedure TArmyView.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(FUnitConcealment, 16, 40);
  Stream.rwWord(FConcealedForPlayers, 41);
  Stream.rwData(FMoraleValues, 32, 42);
end;

procedure TArmyView.MainReadWrite(Stream: TEStorageStream);
var I: Integer;
begin
  inherited MainReadWrite(Stream);
  if smRead in Stream.StorageMode then
    for I := 0 to GetCount - 1 do GetUnit(I).FMoraleValue := FMoraleValues[I];
end;

procedure TArmyView.GetLocation(var Xhx, Yhx, Lhx: Shortint);
begin Xhx := FX; Yhx := FY; Lhx := FL; end;

constructor TArmyEventLog.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FArmyMessages := TStringList.Create;
  FArmyView := TArmyView.Create(nil);
  FDamageValues := TByteList.Create;
  FDamageTypes := TByteList.Create;
end;

destructor TArmyEventLog.Destroy;
begin
  FArmyMessages.Free;
  FArmyView.Free;
  FDamageValues.Free;
  FDamageTypes.Free;
  inherited Destroy;
end;

class function TArmyEventLog.ClassID: Integer;
begin Result := $20218; end;

procedure TArmyEventLog.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwEObject(FArmyView, 15);
  Stream.rwString(FArmyText, 16);
  Stream.rwStrings(FArmyMessages, 17);
  Stream.rwInteger(FArmyIcon, 18);
  Stream.rwStreamProc(19, FDamageValues.LoadFromStream, FDamageValues.SaveToStream);
  Stream.rwStreamProc(20, FDamageTypes.LoadFromStream, FDamageTypes.SaveToStream);
  Stream.rwBool(FGameOver, 21);
end;

function TArmyEventLog.GetLeftIcon: Integer;
begin
  if FArmyView.FPlayer > 0 then
    Result := AoWHSMap.FPlayers.GetPlayers(FArmyView.FPlayer).FPlayerRace
  else Result := 12;
end;

procedure TArmyEventLog.SetArmyView(Value: TArmyView);
begin FArmyView.Assign(Value, AoWEngine); end;

function TArmyEventLog.GetText: string;
begin Result := FArmyText; end;

function TArmyEventLog.LeaderKilled: Boolean;
var I: Integer;
begin
  Result := False;
  I := FArmyView.GetCount;
  while not Result and (I <> 0) do
  begin
    Dec(I);
    Result := (FArmyView.GetUnit(I) is TLeader) and
      (FArmyView.GetUnit(I).GetHitPoints <= FDamageValues[I]);
  end;
end;

function TArmyEventLog.PartyDestroyed: Boolean;
var I: Integer;
begin
  Result := True;
  I := FArmyView.GetCount;
  while Result and (I <> 0) do
  begin
    Dec(I);
    Result := Result and (FArmyView.GetUnit(I).GetHitPoints <= FDamageValues[I]);
  end;
end;

procedure TArmyEventLog.ValidateGameOver;
begin
  FGameOver := LeaderKilled or (PartyDestroyed and
    (AoWHSMap.FPlayers.GetPlayers(FArmyView.FPlayer).FArmies.GetCount = 1));
end;

function TArmyEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
var ShowEvent: Boolean;
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
        ShowEvent := False;
        if (AoWHSMap.FSeatedPlayer = FPlayer) or (AoWHSMap.FSeatedPlayer = FArmyView.FPlayer) then
        begin
          ShowEvent := ShowEvent or ((AoWHSMap.FPlayMode = pmTurn) and
            (wpPartyDamage in AoWEngine.FRegistry.GetClassicWindowPopupEvents));
          ShowEvent := ShowEvent or ((AoWHSMap.FPlayMode = pmSimultaneous) and
            (wpPartyDamage in AoWEngine.FRegistry.GetSimultaneousWindowPopupEvents));
        end;
        ShowEvent := ShowEvent or FGameOver;
        if ShowEvent then
        begin
          AoWHSMap.TriggerExecuteEventLog(Self, False, Done);
          Result := True;
        end;
      end;
  end;
end;

procedure TArmyEventLog.ViewLocation;
var Army: TArmyView;
begin
  Army := FArmyView;
  if (Army <> nil) and (Army.FX <> -1) then CenterViewTo(Army.FX, Army.FY, Army.FL);
end;

constructor TArmyInfoEventLog.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FMessages := TStringList.Create;
  FArmyView := TArmyView.Create(nil);
  FTriggers := [etEvent, etUser, etNewTurn];
end;

destructor TArmyInfoEventLog.Destroy;
begin
  FMessages.Free;
  FArmyView.Free;
  inherited Destroy;
end;

class function TArmyInfoEventLog.ClassID: Integer;
begin Result := $202E9; end;

procedure TArmyInfoEventLog.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwEObject(FArmyView, 15);
  Stream.rwStrings(FMessages, 16);
  Stream.rwData(FSelection, 1, 17);
  Stream.rwString(FTitle, 18);
  Stream.rwString(FText, 19);
  Stream.rwString(FDescription, 20);
end;

procedure TArmyInfoEventLog.SetArmyView(Value: TArmyView);
begin FArmyView.Assign(Value, AoWEngine); end;

function TArmyInfoEventLog.GetText: string;
begin Result := FText; end;

procedure TArmyInfoEventLog.ViewLocation;
var Army: TArmyView;
begin
  Army := FArmyView;
  if (Army <> nil) and (Army.FX <> -1) then CenterViewTo(Army.FX, Army.FY, Army.FL);
end;

function TArmyInfoEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
begin
  Result := False;
  if Trigger in FTriggers then
    case Trigger of
      etUser:
        begin
          AoWHSMap.TriggerExecuteEventLog(Self, False, Done);
          Result := True;
        end;
      etNewTurn:
        if (AoWHSMap.FSeatedPlayer = FPlayer) or (AoWHSMap.FSeatedPlayer = FArmyView.FPlayer) then
        begin
          AoWHSMap.TriggerExecuteEventLog(Self, False, Done);
          Result := True;
        end;
      etEvent:
        if (AoWHSMap.FConnectionType = pcLocal) and
          ((AoWHSMap.FSeatedPlayer = FPlayer) or (AoWHSMap.FSeatedPlayer = FArmyView.FPlayer)) then
        begin
          AoWHSMap.TriggerExecuteEventLog(Self, False, Done);
          Result := True;
        end
        else PlaySample('SFX\EVENTS\NEWEVENT.WAV');
    end;
end;

constructor TArmy.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FX := -1;
  FY := -1;
  FL := -1;
  FDestinationX := -1;
  FDestinationY := -1;
  FDestinationL := -1;
  FIndependentRelation := -1;
end;

destructor TArmy.Destroy;
begin
  if not (msDestroying in AoWHSMap.Status) then AoWHSMap.ArmyDestroyed(GetArmyHS);
  FOnUpdate := nil;
  inherited Destroy;
end;

procedure TArmy.Kill(Selection: Byte);
var I: Integer;
begin
  BeginUpdate;
  for I := GetCount - 1 downto 0 do
    if (Selection shr I) and 1 <> 0 then TAbstractUnit(FChildren.List^[I]).Killed;
  EndUpdate;
end;

function TArmy.GetStrengthEx(Selection: Byte; DamageType: TDamageType): Integer;
var I: Integer;
begin
  Result := 0;
  for I := FChildren.Count - 1 downto 0 do
    if (1 shl I) and Selection <> 0 then
      Inc(Result, TAbstractUnit(FChildren.List^[I]).GetStrength(DamageType));
end;

function TArmy.GetStrengthMaxEx(Selection: Byte; DamageTypes: TDamageTypes): Integer;
var I: Integer;
begin
  Result := 0;
  for I := FChildren.Count - 1 downto 0 do
    if (1 shl I) and Selection <> 0 then
      Inc(Result, TAbstractUnit(FChildren.List^[I]).GetStrengthMax(DamageTypes));
end;

procedure TArmy.ReturnBattleFieldInfo(var Info: TBattleFieldInfo);
var I, Strength: Integer; AUnit: TAbstractUnit;
  Relation: TDiplomaticRelation; Behavior: TGroupBehavior; IncludeUnit: Boolean;
begin
  Relation := DiplomaticRelation(Info.Player, Info.IndependentRelation, FPlayer, FIndependentRelation);
  for I := FChildren.Count - 1 downto 0 do
  begin
    AUnit := TAbstractUnit(FChildren.List^[I]);
    if AUnit.FGroup <> nil then Behavior := AUnit.FGroup.Behavior else Behavior := gbPassive;
    IncludeUnit := (Info.Units = nil) or (Info.Units.FChildren.IndexOf(AUnit) = -1);
    if IncludeUnit and (bfrIgnorePassiveIndependents in Info.Requests) then
      IncludeUnit := (AUnit.FPlayer <> 0) or ((AUnit.FGroup <> nil) and
        (AUnit.FGroup.Behavior <> gbPassive) and (AUnit.FGroup.Behavior <> gbGuard));
    if IncludeUnit and (bfrIgnoreIndependents in Info.Requests) and (AUnit.FPlayer = 0) then
      IncludeUnit := False;
    if IncludeUnit then
    begin
      Strength := AUnit.GetStrengthMax(Info.DamageTypes);
      if Ord(Relation) in Info.FriendlyRelations then Inc(Info.FriendlyStrength, Strength);
      if (Ord(Relation) in Info.EnemyRelations) or (Behavior = gbGuardArea) then Inc(Info.Strength, Strength);
    end;
  end;
end;

function TArmy.HealUnits(Selection: Byte): Boolean;
var I: Integer; AUnit: TAbstractUnit;
begin
  Result := False;
  for I := 0 to GetCount - 1 do
  begin
    if Selection and 1 <> 0 then
    begin
      AUnit := TAbstractUnit(FChildren.List^[I]);
      if AUnit.GetHitPoints <> AUnit.GetHits then
      begin Result := True; AUnit.SetHitPoints(AUnit.GetHits); end;
    end;
    Selection := Selection shr 1;
  end;
end;

function TArmy.CreateGroupID(Selection: Byte): Integer;
var I: Integer;
begin
  I := 0;
  while (Selection and 1 = 0) and (I <> FChildren.Count) do
  begin
    Inc(I);
    Selection := Selection shr 1;
  end;
  if I <> FChildren.Count then Result := TAbstractUnit(FChildren.List^[I]).FUnitID
  else Result := 0;
end;

function TArmy.GetGroup(Selection: Byte): TAIGroup;
var Different: Boolean; I: Integer; Found: Boolean;
begin
  Result := nil;
  Different := False;
  I := 0;
  Found := False;
  while (I <> FChildren.Count) and not Different do
  begin
    if Selection and 1 <> 0 then
      if not Found then
      begin
        Result := TAbstractUnit(FChildren.List^[I]).FGroup;
        Found := True;
      end
      else Different := Result <> TAbstractUnit(FChildren.List^[I]).FGroup;
    Selection := Selection shr 1;
    Inc(I);
  end;
  if Boolean(Byte(Different) or Byte(not Found)) then Result := nil;
end;

procedure TArmy.SetGroup(Selection: Byte; Group: TAIGroup);
var I: Integer;
begin
  for I := 0 to FChildren.Count - 1 do
  begin
    if Selection and 1 <> 0 then Group.AddUnit(TAbstractUnit(FChildren.List^[I]));
    Selection := Selection shr 1;
  end;
end;

function TArmy.GetGroupSelection(GroupID: Integer): Byte;
var I: Integer;
begin
  Result := 0;
  for I := FChildren.Count - 1 downto 0 do
  begin
    Result := Result shl 1;
    if GroupID = TAbstractUnit(FChildren.List^[I]).FGroupID then Result := Result or 1;
  end;
end;

function TArmy.GetBehavior(Selection: Byte): TGroupBehavior;
var Group: TAIGroup;
begin
  Group := GetGroup(Selection);
  if Group <> nil then Result := Group.Behavior else Result := gbNone;
end;

procedure TArmy.SetBehavior(Selection: Byte; Behavior: TGroupBehavior);
var Group: TAIGroup; I: Integer;
begin
  Group := AoWHSMap.FAIGroupManager.CreateGroup(FPlayer, FIndependentRelation, Behavior);
  if Group <> nil then
  begin
    for I := 0 to FChildren.Count - 1 do
    begin
      if Selection and 1 <> 0 then Group.AddUnit(TAbstractUnit(FChildren.List^[I]));
      Selection := Selection shr 1;
    end;
    Group.Release;
  end;
end;

function TArmy.GetOldAIBehavior: TGroupBehavior;
var I: Integer;
begin
  Result := gbNone;
  I := GetCount;
  while (Result = gbNone) and (I <> 0) do
  begin
    Dec(I);
    Result := TGroupBehavior(GetUnit(I).F_AbstractUnit_38);
  end;
end;

procedure TArmy.InitializeGroupBehavior;
var Selection: Byte; Index: Integer; Behavior: TGroupBehavior; AHero: THero;
begin
  Selection := $FF;
  AHero := Hero(Selection, [htLeader, htHeroLeader]);
  if AHero <> nil then
  begin
    Index := IndexOf(AHero);
    if Index <> -1 then
    begin
      SetBehavior(Byte(1) shl Index, gbFortify);
      Selection := Selection and not (Byte(1) shl Index);
    end;
  end;
  Index := IndexOfTransporter(Selection);
  if (Index <> -1) and (FOldAIBehavior = gbNone) then
    Selection := Selection and not (Byte(1) shl Index);
  if Selection <> 0 then
  begin
    Behavior := FOldAIBehavior;
    if Behavior = gbNone then
      if (FPlayer = 0) and (AoWHSMap.GetIndependentAIMode <> iaOff) then
      begin
        if (FX <> -1) and
          (AoWHSMap.MapContainer.GetField(FX, FY, FL).FindNoneTransparentHS(TPlayerStructure) = nil) then
          if FIndependentRelation >= 0 then Behavior := gbPatrol else Behavior := gbGuardArea
        else Behavior := gbPassive;
      end
      else Behavior := AoWHSMap.FPlayers.GetPlayers(FPlayer).FAIControl.GetRandomGroupBehavior;
    SetBehavior(Selection, Behavior);
  end;
end;

procedure TArmy.UpdateGroupBehavior;
var Selection: Byte; Index: Integer; Behavior: TGroupBehavior;
begin
  Selection := GetGroupSelection(0);
  if Selection <> 0 then
  begin
    Index := IndexOfTransporter(Selection);
    if Index <> -1 then
    begin
      Selection := Selection and not (Byte(1) shl Index);
      if TAbstractUnit(FChildren.List^[Index]).FGroupID = 0 then
        SetBehavior(Byte(1) shl Index, gbTransport);
    end;
    Behavior := gbPassive;
    if (FPlayer = 0) and (Hero(Selection, [htHero]) <> nil) then Behavior := gbScout
    else if (FPlayer = 0) and (AoWHSMap.GetIndependentAIMode <> iaOff) and (FX <> -1) then
      if AoWHSMap.MapContainer.GetField(FX, FY, FL).FindNoneTransparentHS(TPlayerStructure) = nil then
        if FIndependentRelation >= 0 then Behavior := gbPatrol else Behavior := gbGuardArea;
    if Selection <> 0 then
    begin
      Index := IndexOfBehavior(Behavior);
      if Index = -1 then SetBehavior(Selection, Behavior)
      else SetGroup(Selection, TAbstractUnit(FChildren.List^[Index]).FGroup);
    end;
  end;
end;

function TArmy.CreateID(Selection: Byte): TArmyID;
var ID: TArmyID; I: Integer;
begin
  ID := TArmyID.Create(nil);
  ID.FX := FX;
  ID.FY := FY;
  ID.FL := FL;
  ID.FPlayer := FPlayer;
  for I := 0 to GetCount - 1 do
  begin
    if Selection and 1 <> 0 then ID.FUnitIDs.Add(TAbstractUnit(FChildren.List^[I]).FUnitID);
    Selection := Selection shr 1;
  end;
  Result := ID;
end;

class function TArmy.ClassID: Integer;
begin Result := $20216; end;

function TArmy.GetArmyHS: TArmyHS;
var X, Y, L: Shortint;
begin
  GetLocation(X, Y, L);
  if X <> -1 then
    Result := TArmyHS(AoWHSMap.MapContainer.GetField(X, Y, L).FindOwnedChild($20217))
  else Result := nil;
end;

function TArmy.GetEngine: TEngine;
begin Result := AoWEngine; end;

procedure TArmy.AssignSettings(Army: TArmy);
begin
  FDestinationX := Army.FDestinationX;
  FDestinationY := Army.FDestinationY;
  FDestinationL := Army.FDestinationL;
  FPlayer := Army.FPlayer;
end;

procedure TArmy.SetFullyConcealed(Value: Boolean);
begin
  if Value <> (asFullyConcealed in FStatus) then
  begin
    if Value then FStatus := FStatus + [asFullyConcealed]
    else FStatus := FStatus - [asFullyConcealed];
    if (asActivated in FStatus) and (FX <> -1) then
      AoWHSMap.ScannerIconsChangedRad(FX, FY, FL, 0);
  end;
end;

function TArmy.GetFullyConcealed: Boolean;
begin Result := asFullyConcealed in FStatus; end;

procedure TArmy.UpdateConcealment;
var Concealed: Boolean; ALeader: TLeader; Changed, ShowCrown: Boolean;
begin
  if asActivated in FStatus then
  begin
    if (FConcealedUnits <> 0) and (AoWHSMap.FSeatedPlayer <> FPlayer) and
      not (msEditting in AoWHSMap.Status) then Concealed := GetConcealedForPlayer(AoWHSMap.FSeatedPlayer)
    else Concealed := False;
    ALeader := Leader($FF);
    ShowCrown := ALeader <> nil;
    if ShowCrown and Concealed then
      if (FConcealedUnits shr IndexOf(ALeader)) and 1 <> 0 then ShowCrown := False;
    Changed := False;
    if ShowCrown then FStatus := FStatus + [asShowCrown] else FStatus := FStatus - [asShowCrown];
    if Concealed <> (asConcealed in FStatus) then
    begin
      if Concealed then FStatus := FStatus + [asConcealed] else FStatus := FStatus - [asConcealed];
      Changed := True;
    end;
    Concealed := Concealed and (GetCount = ConcealedUnitsCount);
    if Concealed <> GetFullyConcealed then
    begin SetFullyConcealed(Concealed); Changed := True; end;
    if Changed then TriggerOnUpdateEvent;
  end;
end;

procedure TArmy.SetXYL(X, Y, L: Shortint);
begin
  FX := X;
  FY := Y;
  FL := L;
  if UpdateCount = 0 then UpdateConcealedUnits;
end;

function TArmy.GetRace(Selection: Byte): Integer;
var Same: Boolean; I, Race: Integer;
begin
  Result := -1;
  Same := True;
  for I := 0 to GetCount - 1 do
  begin
    if Selection and 1 <> 0 then
    begin
      Race := TAbstractUnit(FChildren.List^[I]).GetRace;
      if Race <> -1 then
        if Result <> -1 then Same := Same and (Race = Result)
        else Result := Race;
    end;
    Selection := Selection shr 1;
  end;
  if not Same then Result := -1;
end;

function TArmy.GetUpkeep: Byte;
begin Result := FUpkeep; end;

procedure TArmy.ResetDestinationPos;
begin FDestinationX := -1; FDestinationY := -1; FDestinationL := -1; end;

procedure TArmy.SetDestinationPos(X, Y, L: Shortint);
begin FDestinationX := X; FDestinationY := Y; FDestinationL := L; end;

function TArmy.ConcealedUnitsCount: Integer;
var Selection: Byte;
begin
  Selection := FConcealedUnits;
  Result := 0;
  while Selection <> 0 do
  begin
    if Selection and 1 <> 0 then Inc(Result);
    Selection := Selection shr 1;
  end;
end;

procedure TArmy.UpdateConcealedUnits;
var I: Integer; Field: TAoWMapField;
begin
  if (FX <> -1) and (FL <> -1) and (asActivated in FStatus) then
  begin
    FConcealedUnits := 0;
    I := FChildren.Count;
    Field := TAoWMapField(AoWHSMap.MapContainer.GetField(FX, FY, FL));
    while I <> 0 do
    begin
      Dec(I);
      FConcealedUnits := FConcealedUnits shl 1;
      if TAbstractUnit(FChildren.List^[I]).ConcealedOnMapF(Field) then
        FConcealedUnits := FConcealedUnits or 1;
    end;
  end;
end;

procedure TArmy.UpdateUpkeep;
var Upkeep: Byte; I: Integer;
begin
  Upkeep := 0;
  for I := 0 to GetCount - 1 do Inc(Upkeep, TAbstractUnit(FChildren.List^[I]).GetUpkeep);
  if (Upkeep <> FUpkeep) and (asActivated in FStatus) then
    AoWHSMap.FPlayers.GetPlayers(FPlayer).SetArmyUpkeep(Upkeep - FUpkeep +
      AoWHSMap.FPlayers.GetPlayers(FPlayer).FArmyUpkeep);
  FUpkeep := Upkeep;
end;

procedure TArmy.Changed;
begin Update; end;

resourcestring
  UnitsDrownRStr = 'Units Drowned';
  UnitsBurnedRStr = 'Units Burned';
  UnitsCrushedRStr = 'Units Crushed';
  ArmyInherentRStr = 'Inherent';
const
  ArmySelectionMasks: array[0..8] of Byte = (0, 1, 3, 7, 15, 31, 63, 127, 255);

procedure TArmy.ValidateTerrainEx(TerrainType, OverlayType, Player: Shortint);
var Transport: TAbstractUnit; Selection: Byte; I: Integer;
  Log: TArmyEventLog; AUnit: TAbstractUnit;
begin
  Transport := Transporter($FF);
  if (Transport = nil) or not Transport.ValidTerrain(TerrainType, OverlayType) then
  begin
    Selection := 0;
    for I := GetCount - 1 downto 0 do
    begin
      Selection := Selection shl 1;
      if not TAbstractUnit(FChildren.List^[I]).ValidTerrain(TerrainType, OverlayType) then
        Selection := Selection or 1;
    end;
  end
  else Selection := 0;
  if Selection <> 0 then
  begin
    if not (msEditting in AoWHSMap.Status) and (AoWHSMap.FDay <> 0) then
    begin
      BeginUpdate;
      Log := TArmyEventLog.Create(nil);
      Log.FPlayer := Player;
      if TerrainType in [0, 10] then
      begin
        Log.FArmyText := TranslateRStr(UnitsDrownRStr);
        Log.FArmyMessages.Add(TranslateRStr(UnitsDrownRStr));
        Log.FArmyIcon := 3;
      end
      else case TerrainType of
        9:
        begin
          Log.FArmyText := TranslateRStr(UnitsBurnedRStr);
          Log.FArmyMessages.Add(TranslateRStr(UnitsBurnedRStr));
          Log.FArmyIcon := 0;
        end;
      else
        Log.FArmyText := TranslateRStr(UnitsCrushedRStr);
        Log.FArmyMessages.Add(TranslateRStr(UnitsCrushedRStr));
        Log.FArmyIcon := 2;
      end;
      Log.FArmyView.Setup(Self, $FF);
      for I := 0 to GetCount - 1 do
      begin
        AUnit := GetUnit(I);
        if (Selection shr I) and 1 <> 0 then
        begin
          Log.FDamageValues.Add(AUnit.GetHitPoints);
          Log.FDamageTypes.Add(9);
          AUnit.SetHitPoints(0);
        end
        else
        begin
          Log.FDamageValues.Add(0);
          Log.FDamageTypes.Add(9);
        end;
      end;
      Log.ValidateGameOver;
      DistributeLocationEventLog(Log, FPlayer, FX, FY, FL, True);
      Log.Release;
      EndUpdate;
    end;
    Validate;
  end;
end;

procedure TArmy.ValidateTerrain(TerrainType, OverlayType: Shortint);
begin
  ValidateTerrainEx(TerrainType, OverlayType, FPlayer);
end;

procedure TArmy.Validate;
var I: Integer; AUnit: TAbstractUnit; NewUnit: TUnit;
begin
  AoWHSMap.LockGameOverEvent;
  BeginUpdate;
  for I := FChildren.Count - 1 downto 0 do
  begin
    AUnit := TAbstractUnit(FChildren.List^[I]);
    if AUnit.GetHitPoints = 0 then
      if AUnit.GetAbilityEnabled($6B) then
      begin
        NewUnit := TUnit.Create(nil);
        NewUnit.SetUnitResource(AoWHSSet.FUnitResources.GetUnitResource($98));
        AUnit.Killed;
        AddUnit(NewUnit);
      end
      else AUnit.Killed;
  end;
  EndUpdate;
  AoWHSMap.UnlockGameOverEvent;
end;

procedure TArmy.UpdateFormation;
var I, Level, UnitLevel: Integer; AUnit: TAbstractUnit; SourceName: string;
begin
  Level := 0;
  for I := FChildren.Count - 1 downto 0 do
  begin
    AUnit := TAbstractUnit(FChildren.List^[I]);
    AUnit.UpdateMoraleValue;
    if AUnit.GetAbilityEnabled($2E) or (AUnit.GetAbilityLevel($2E) > 0) then
    begin
      TLeadershipAbility(AoWHSSet.FAbilityControl.GetAbility($2E)).ResetExternalSource(AUnit);
      UnitLevel := AUnit.GetAbilityLevel($2E);
      if UnitLevel > Level then
      begin
        Level := UnitLevel;
        SourceName := AUnit.GetAbilityOwner($2E).GetOwnerName;
        if SourceName = TranslateRStr(ArmyInherentRStr) then SourceName := AUnit.GetName;
      end;
    end;
  end;
  if Level > 0 then
    for I := FChildren.Count - 1 downto 0 do
    begin
      AUnit := TAbstractUnit(FChildren.List^[I]);
      if AUnit.GetAbilityLevel($2E) < Level then
        TLeadershipAbility(AoWHSSet.FAbilityControl.GetAbility($2E)).SetExternalSource(AUnit, Level, SourceName);
    end;
end;

procedure TArmy.Update;
begin
  if (UpdateCount = 0) and (asActivated in FStatus) then
  begin
    LockChanged;
    SortUnits;
    UpdateVisibilityRanges;
    UpdateUnfog;
    UpdateUpkeep;
    UpdateConcealedUnits;
    UpdateConcealment;
    UpdateFormation;
    UpdateIndependentRelation;
    if (msEditting in AoWHSMap.Status) and (FX <> -1) then
      AoWHSMap.ScannerIconsChangedRad(FX, FY, FL, 0);
    UnlockChanged;
    TriggerOnUpdateEvent;
  end;
end;

procedure TArmy.TriggerOnUpdateEvent;
begin
  if (UpdateCount = 0) and (asActivated in FStatus) then
  begin
    AoWHSMap.ArmyChanged(Self);
    if Assigned(FOnUpdate) then FOnUpdate(Self);
  end;
end;

procedure TArmy.Activate;
var I: Integer; AUnit: TAbstractUnit;
begin
  Assert(not (asActivated in FStatus), 'Army already activated');
  if FOldAIBehavior = gbNone then FOldAIBehavior := GetOldAIBehavior;
  for I := FChildren.Count - 1 downto 0 do
  begin
    AUnit := TAbstractUnit(FChildren.List^[I]);
    if not (usActivated in AUnit.FUnitStatus) then AUnit.Activate;
  end;
  FStatus := FStatus + [asActivated];
  FUpkeep := 0;
  if FPlayer <> -1 then AoWHSMap.FPlayers.GetPlayers(FPlayer).FArmies.AddChild(Self);
  { Original treats X = 0 as an unset location. }
  if FX = 0 then begin FX := -1; FY := -1; FL := -1; end;
  Update;
end;

procedure TArmy.Deactivate;
var I: Integer; AUnit: TAbstractUnit;
begin
  if asActivated in FStatus then
  begin
    if FUnfogRange <> 0 then
    begin
      AoWHSMap.FogArea(FX, FY, FL, FUnfogRange);
      FUnfogRange := 0;
    end;
    for I := FChildren.Count - 1 downto 0 do
    begin
      AUnit := TAbstractUnit(FChildren.List^[I]);
      if usActivated in AUnit.FUnitStatus then AUnit.Deactivate;
    end;
    if FPlayer <> -1 then
    begin
      AoWHSMap.FPlayers.GetPlayers(FPlayer).FArmies.RemoveChild(Self);
      AoWHSMap.FPlayers.GetPlayers(FPlayer).SetArmyUpkeep(
        AoWHSMap.FPlayers.GetPlayers(FPlayer).FArmyUpkeep - FUpkeep);
    end;
    FStatus := FStatus - [asActivated];
  end;
end;

function TArmy.ValidateSelection(Selection: Byte): Byte;
begin
  Result := Selection and ArmySelectionMasks[FChildren.Count];
end;

function TArmy.SelectionCount(Selection: Byte): Integer;
begin
  Selection := Selection and ArmySelectionMasks[FChildren.Count];
  Result := 0;
  while Selection <> 0 do
  begin
    if Selection and 1 <> 0 then Inc(Result);
    Selection := Selection shr 1;
  end;
end;

function TArmy.ValidateMoveSelection(Selection: Byte): Byte;
begin
  Result := ValidateSelection(Selection);
  if (IndexOfTransporter($FF) <> -1) and (UnitsInTransporter and not Selection <> 0) and
    (Transporter(Selection) <> nil) then
    Result := Result and not (Byte(1) shl FChildren.IndexOf(Transporter($FF)));
end;

procedure TArmy.Select;
begin FStatus := FStatus + [asSelected]; end;

procedure TArmy.Unselect;
begin FStatus := FStatus - [asSelected]; end;

function TArmy.GetPlayer: Shortint;
begin Result := FPlayer; end;

function TArmy.GetUnitConcealed(Index: Integer): Boolean;
var Field: TAoWMapField;
begin
  Field := TAoWMapField(AoWHSMap.MapContainer.GetField(FX, FY, FL));
  Result := TAbstractUnit(FChildren.List^[Index]).ConcealedOnMapF(Field);
end;

function TArmy.GetUnitConcealedForPlayer(Index: Integer; Player: Shortint): Boolean;
var Field: TAoWMapField;
begin
  if (Player <> FPlayer) and (Player <> -1) and (FX <> -1) then
  begin
    Field := TAoWMapField(AoWHSMap.MapContainer.GetField(FX, FY, FL));
    Result := TAbstractUnit(FChildren.List^[Index]).ConcealedOnMapF(Field) and GetConcealedForPlayer(Player);
  end
  else Result := False;
end;

function TArmy.GetUnitsConcealedForPlayer(Selection: Byte; Player: Shortint): Boolean;
begin
  Selection := ValidateSelection(Selection);
  if Selection = (FConcealedUnits and Selection) then Result := GetConcealedForPlayer(Player)
  else Result := False;
end;

function TArmy.GetConcealedForPlayer(Player: Shortint): Boolean;
var Level: TMapLevel; Field: TAoWMapField; Msg: TMapFieldMsg; Walk: THNWalkData;
begin
  if Player <> -1 then
  begin
    Result := True;
    Level := AoWHSMap.MapContainer.MapLevels[FL];
    Msg.MsgID := $110B;
    Msg.Result := 0;
    Msg.Param[1] := Player;
    InitHNWalk(Walk, FX, FY, 0);
    while Result and (Walk.Radius < 8) do
    begin
      if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
      begin
        Field := TAoWMapField(Level.GetField(Walk.X, Walk.Y));
        if Field.FFieldFlags and $1000 <> 0 then
        begin
          Msg.Param[0] := Walk.Radius;
          Field.SendMapFieldMsg(Msg);
          Result := Msg.Result = 0;
        end;
      end;
      WalkToNextHN(Walk);
    end;
  end
  else Result := False;
end;

procedure TArmy.SetPlayer(Player: Shortint);
var I: Integer;
begin
  if AoWHSMap.FPlayers.GetPlayers(Player) = nil then Player := 0;
  if Player <> FPlayer then
  begin
    BeginUpdate;
    if asActivated in FStatus then
    begin
      if FPlayer <> -1 then
      begin
        AoWHSMap.FPlayers.GetPlayers(FPlayer).SetArmyUpkeep(
          AoWHSMap.FPlayers.GetPlayers(FPlayer).FArmyUpkeep - FUpkeep);
        AoWHSMap.FPlayers.GetPlayers(FPlayer).FArmies.RemoveChild(Self);
      end;
      FPlayer := Player;
      if FPlayer <> -1 then
      begin
        AoWHSMap.FPlayers.GetPlayers(FPlayer).SetArmyUpkeep(
          AoWHSMap.FPlayers.GetPlayers(FPlayer).FArmyUpkeep + FUpkeep);
        AoWHSMap.FPlayers.GetPlayers(FPlayer).FArmies.AddChild(Self);
      end;
      for I := FChildren.Count - 1 downto 0 do TAbstractUnit(FChildren.List^[I]).SetPlayer(FPlayer);
      if FX <> -1 then AoWHSMap.ScannerIconsChangedRad(FX, FY, FL, 0);
      if (FPlayer > 0) and (AoWHSMap.FDay > 0) then
        if AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType <> ptHuman then SetBehavior($FF, gbPassive);
      UpdateUnfog;
      UpdateExploration;
    end
    else FPlayer := Player;
    EndUpdate;
  end;
end;

function TArmy.ImmunityTypes(Selection: Byte): TDamageTypes;
var I: Integer;
begin
  Result := dtAll;
  I := 0;
  while (Result <> []) and (I <> GetCount) do
  begin
    if Selection and 1 <> 0 then
      Result := Result * TAbstractUnit(FChildren.List^[I]).GetImmunityTypes;
    Selection := Selection shr 1;
    Inc(I);
  end;
end;

function TArmy.ObtainValue(Selection: Byte): Integer;
var I: Integer;
begin
  Result := 0;
  for I := 0 to FChildren.Count - 1 do
  begin
    if Selection and 1 <> 0 then Inc(Result, TAbstractUnit(FChildren.List^[I]).GetObtainValue);
    Selection := Selection shr 1;
  end;
end;

function TArmy.MovePoints(Selection: Byte): Shortint;
var I: Integer; Transport, AUnit: TAbstractUnit;
begin
  Transport := Transporter(Selection);
  if Transport <> nil then Result := Transport.GetMovePoints
  else if Selection <> 0 then
  begin
    Result := 50;
    for I := 0 to GetCount - 1 do
    begin
      if Selection and 1 <> 0 then
      begin
        AUnit := TAbstractUnit(FChildren.List^[I]);
        if AUnit.GetMovePoints < Result then Result := AUnit.GetMovePoints;
      end;
      Selection := Selection shr 1;
    end;
  end
  else Result := 0;
end;

function TArmy.Moves(Selection: Byte): Shortint;
var I: Integer; Transport, AUnit: TAbstractUnit;
begin
  Transport := Transporter(Selection);
  if Transport <> nil then Result := Transport.GetMoves
  else if Selection <> 0 then
  begin
    Result := 50;
    for I := 0 to GetCount - 1 do
    begin
      if Selection and 1 <> 0 then
      begin
        AUnit := TAbstractUnit(FChildren.List^[I]);
        if AUnit.GetMoves < Result then Result := AUnit.GetMoves;
      end;
      Selection := Selection shr 1;
    end;
  end
  else Result := 0;
end;

function TArmy.MoveTypes(Selection: Byte): TMoveTypes;
var I: Integer; Transport: TAbstractUnit;
begin
  Transport := Transporter(Selection);
  if Transport <> nil then Result := Transport.GetMoveTypes
  else
  begin
    Result := [];
    for I := 0 to GetCount - 1 do
    begin
      if Selection and 1 <> 0 then
        Result := Result + TAbstractUnit(FChildren.List^[I]).GetMoveTypes;
      Selection := Selection shr 1;
    end;
  end;
end;

function TArmy.GetPartyMoves(Selection: Byte): TMoveTypes;
var Transport: TAbstractUnit; Common, Moves: TMoveTypes; MoveType, I: Integer;
begin
  Transport := Transporter(Selection);
  if Transport = nil then
  begin
    Common := [mtWalking..mtTunneling];
    MoveType := Ord(mtFlying);
    for I := 0 to GetCount - 1 do
      if (1 shl I) and Selection <> 0 then
      begin
        Moves := TAbstractUnit(FChildren.List^[I]).GetMoveTypes;
        Common := Common * Moves;
        if MoveType <> -1 then
          if TMoveType(MoveType) = mtFlying then
          begin
            if not (mtFlying in Moves) then
              if mtSwimming in Moves then MoveType := Ord(mtSwimming)
              else MoveType := Ord(mtWalking);
          end
          else if TMoveType(MoveType) = mtSwimming then
          begin
            if [mtFlying, mtSwimming] * Moves = [] then MoveType := Ord(mtWalking);
          end
          else if TMoveType(MoveType) = mtWalking then
            if [mtWalking, mtFlying, mtForestry..mtLavaCrossing] * Moves = [] then MoveType := -1;
      end;
    { Original leaves Result uninitialized when the units share no movement mode. }
    if MoveType <> -1 then Result := [TMoveType(MoveType)];
    Result := Result + Common;
  end
  else Result := Transport.GetMoveTypes;
end;

function TArmy.MoveOnMovePoints(Selection: Byte; TerrainType, OverlayType: Shortint): Integer;
var I: Integer; Table, UnitTable: TMovePointTable; Transport: TAbstractUnit;
begin
  FillChar(Table, SizeOf(Table), 1);
  Transport := Transporter(Selection);
  if Transport <> nil then Transport.CreateMovePointTable(Table)
  else
    for I := 0 to GetCount - 1 do
    begin
      if Selection and 1 <> 0 then
      begin
        TAbstractUnit(FChildren.List^[I]).CreateMovePointTable(UnitTable);
        MaximizeMovePointTable(Table, UnitTable);
      end;
      Selection := Selection shr 1;
    end;
  Result := Table[TerrainType, OverlayType];
end;

procedure TArmy.CreateMovePointTable(Selection: Byte; var Table);
var I, Count: Integer; UnitTable: TMovePointTable; Transport: TAbstractUnit;
begin
  Count := 0;
  FillChar(Table, SizeOf(TMovePointTable), 1);
  Transport := Transporter(Selection);
  if Transport <> nil then
  begin
    Transport.CreateMovePointTable(TMovePointTable(Table));
    Inc(Count);
  end
  else
    for I := 0 to GetCount - 1 do
    begin
      if Selection and 1 <> 0 then
      begin
        TAbstractUnit(FChildren.List^[I]).CreateMovePointTable(UnitTable);
        MaximizeMovePointTable(Table, UnitTable);
        Inc(Count);
      end;
      Selection := Selection shr 1;
    end;
  if Count = 0 then FillChar(Table, SizeOf(TMovePointTable), -1);
end;

function TArmy.ValidTerrainEx(Selection: Byte; TerrainType, OverlayType: Shortint): Boolean;
var I: Integer; Transport: TAbstractUnit;
begin
  Transport := Transporter(Selection);
  if Transport = nil then
  begin
    I := 0;
    Result := True;
    while (Byte(I <> GetCount) and Byte(Result) <> 0) do
    begin
      if (1 shl I) and Selection <> 0 then
        Result := TAbstractUnit(FChildren.List^[I]).ValidTerrain(TerrainType, OverlayType);
      Inc(I);
    end;
  end
  else Result := Transport.ValidTerrain(TerrainType, OverlayType);
end;

function TArmy.ValidTerrain(TerrainType, OverlayType: Shortint): Boolean;
var I: Integer; Transport: TAbstractUnit;
begin
  Transport := Transporter($FF);
  if Transport = nil then
  begin
    I := 0;
    Result := True;
    while (Byte(I <> GetCount) and Byte(Result) <> 0) do
    begin
      Result := TAbstractUnit(FChildren.List^[I]).ValidTerrain(TerrainType, OverlayType);
      Inc(I);
    end;
  end
  else Result := Transport.ValidTerrain(TerrainType, OverlayType);
end;

function TArmy.CanPlace(X, Y, L: Shortint): Boolean;
var Field: TMapField; I: Integer;
begin
  Field := AoWHSMap.MapContainer.GetField(X, Y, L);
  Result := ValidTerrain(Field.TerrainType, Field.OverlayType);
  I := 0;
  if not (asActivated in FStatus) then
    while Result and (I <> FChildren.Count) do
    begin
      Result := TAbstractUnit(FChildren.List^[I]).CanActivate;
      Inc(I);
    end;
end;

procedure TArmy.MovedTo(OldField, NewField: TMapField; MaxCost: Integer);
var AUnit: TAbstractUnit; I: Integer;
begin
  BeginUpdate;
  FUserMode := FUserMode - [aumGuard];
  AUnit := Transporter($FF);
  if AUnit = nil then
    for I := FChildren.Count - 1 downto 0 do
      TAbstractUnit(FChildren.List^[I]).MovedTo(OldField, NewField, MaxCost)
  else
  begin
    AUnit.MovedTo(OldField, NewField, MaxCost);
    for I := FChildren.Count - 1 downto 0 do
    begin
      AUnit := TAbstractUnit(FChildren.List^[I]);
      if not AUnit.GetTransporter then AUnit.MovedTo(OldField, NewField, 0);
    end;
  end;
  UpdateExploration;
  EndUpdate;
end;

function TArmy.MaxSize: Integer;
var I, Capacity: Integer;
begin
  Result := 8;
  for I := 0 to GetCount - 1 do
  begin
    Capacity := TAbstractUnit(FChildren.List^[I]).GetTransportCapacity;
    if (Capacity <> 0) and (Result > Capacity + 1) then Result := Capacity + 1;
  end;
end;

function TArmy.Hero(Selection: Byte; Types: THeroTypes): THero;
var I: Integer; AUnit: TAbstractUnit;
begin
  I := 0;
  Result := nil;
  while (I <> GetCount) and (Result = nil) do
  begin
    if Selection and 1 <> 0 then
    begin
      AUnit := TAbstractUnit(FChildren.List^[I]);
      if (AUnit is THero) and (THero(AUnit).GetHeroType in Types) then Result := THero(AUnit);
    end;
    Selection := Selection shr 1;
    Inc(I);
  end;
end;

function TArmy.Leader(Selection: Byte): TLeader;
var I: Integer;
begin
  I := 0;
  Result := nil;
  while (I <> GetCount) and (Result = nil) do
  begin
    if Selection and 1 <> 0 then
      if TAbstractUnit(FChildren.List^[I]).ClassID = $20232 then
        Result := TLeader(FChildren.List^[I]);
    Selection := Selection shr 1;
    Inc(I);
  end;
end;

function TArmy.Transporter(Selection: Byte): TAbstractUnit;
var I: Integer;
begin
  I := 0;
  Result := nil;
  while (I <> GetCount) and (Result = nil) do
  begin
    if Selection and 1 <> 0 then
      if TAbstractUnit(FChildren.List^[I]).GetTransporter then
        Result := TAbstractUnit(FChildren.List^[I]);
    Selection := Selection shr 1;
    Inc(I);
  end;
end;

function TArmy.IndexOfTransporter(Selection: Byte): Integer;
begin
  Result := GetCount;
  while Result <> 0 do
  begin
    Dec(Result);
    if ((1 shl Result) and Selection <> 0) and TAbstractUnit(FChildren.List^[Result]).GetTransporter then Exit;
  end;
  Result := -1;
end;

function TArmy.UnitsInTransporter: Byte;
var I: Integer; Field: TMapField;
begin
  if FX <> -1 then
  begin
    Field := AoWHSMap.MapContainer.GetField(FX, FY, FL);
    I := 0;
    Result := 0;
    while I <> GetCount do
    begin
      if not TAbstractUnit(FChildren.List^[I]).ValidTerrain(Field.TerrainType, Field.OverlayType) then
        Result := Result + (Byte(1) shl I);
      Inc(I);
    end;
  end
  else Result := 0;
end;

procedure TArmy.UpdateVisibilityRanges;
var I: Integer; TrueVision, Vision, Range: Byte;
begin
  Vision := 0;
  TrueVision := 0;
  for I := 0 to FChildren.Count - 1 do
  begin
    Range := TAbstractUnit(FChildren.List^[I]).VisibilityRange;
    if Range > Vision then Vision := Range;
    Range := TAbstractUnit(FChildren.List^[I]).TrueVisionRange;
    if TrueVision < Range then TrueVision := Range;
  end;
  FVisibilityRanges := TrueVision shl 4 + Vision;
end;

function TArmy.VisibilityRange: Byte;
begin Result := FVisibilityRanges and $F; end;

function TArmy.TrueVisionRange: Byte;
begin Result := FVisibilityRanges shr 4; end;

procedure TArmy.TurnUnFogOff;
var Range: Byte;
begin
  if asActivated in FStatus then
  begin
    Range := FUnfogRange;
    if Range <> 0 then
    begin
      AoWHSMap.FogArea(FX, FY, FL, Range);
      FUnfogRange := 0;
    end;
  end;
end;

procedure TArmy.UpdateExploration;
var Player: Integer;
begin
  if asActivated in FStatus then
    for Player := 1 to AoWHSMap.FPlayers.GetCount - 1 do
      if (Player = FPlayer) or
        (AoWHSMap.FPlayers.GetPlayers(FPlayer).FDiplomaticRelations.GetDiplomaticRelation(Player) = drAlliance) then
        AoWHSMap.ExploreArea(FX, FY, FL, Player, VisibilityRange);
end;

procedure TArmy.UpdateUnfog;
var Range: Integer;
begin
  if asActivated in FStatus then
  begin
    if (AoWHSMap.FSeatedPlayer <> -1) and ((AoWHSMap.FSeatedPlayer = FPlayer) or
      (AoWHSMap.FPlayers.GetPlayers(FPlayer).FDiplomaticRelations.GetDiplomaticRelation(AoWHSMap.FSeatedPlayer) = drAlliance)) then
      Range := VisibilityRange
    else Range := 0;
    if Range <> FUnfogRange then
    begin
      if FUnfogRange <> 0 then AoWHSMap.FogArea(FX, FY, FL, FUnfogRange);
      FUnfogRange := Range;
      if FX <> -1 then
      begin
        if FUnfogRange <> 0 then AoWHSMap.UnFogArea(FX, FY, FL, FUnfogRange);
      end
      else FUnfogRange := 0;
    end;
  end;
end;

function TArmy.CanAddUnit(AUnit: TAbstractUnit): Boolean;
var HasTransporter: Boolean; Field: TMapField;
begin
  if asActivated in FStatus then
  begin
    Result := (GetCount < MaxSize) and AUnit.CanAddToList(Self);
    HasTransporter := IndexOfTransporter($FF) <> -1;
    if Result and not HasTransporter and (FX <> -1) and (FX <> 0) and
      not (amDisableTerrainValidation in FMode) then
    begin
      { Original skips terrain validation on the zero X column. }
      Field := AoWHSMap.MapContainer.GetField(FX, FY, FL);
      Result := AUnit.ValidTerrain(Field.TerrainType, Field.OverlayType);
    end;
    if Result and AUnit.GetTransporter then
      Result := not HasTransporter and (AUnit.GetTransportCapacity >= GetCount);
  end
  else Result := True;
end;

function TArmy.CanAddUnits(Units: TUnitList): TAddUnitsResult;
var I, TransportCount: Integer; Transport: TAbstractUnit;
begin
  TransportCount := 0;
  for I := 0 to Units.GetCount - 1 do
    if Units.GetUnit(I).GetTransporter then Inc(TransportCount);
  if IndexOfTransporter($FF) <> -1 then Inc(TransportCount);
  if TransportCount <= 1 then
  begin
  if TransportCount = 1 then
  begin
    Transport := Transporter($FF);
    if Transport = nil then
      for I := 0 to Units.GetCount - 1 do
        if Units.GetUnit(I).GetTransporter then Transport := Units.GetUnit(I);
    if Units.GetCount + GetCount <= Transport.GetTransportCapacity + 1 then Result := arOK
    else Result := arTooManyUnits;
  end
  else if Units.GetCount + GetCount <= 8 then
  begin
    I := 0;
    { Original repeats the list count test before testing each candidate. }
    if I <> Units.GetCount then
      while (I <> Units.GetCount) and CanAddUnit(Units.GetUnit(I)) do Inc(I);
    if I <> Units.GetCount then Result := arInvalidMoveType else Result := arOK;
  end
  else Result := arTooManyUnits;
  end
  else Result := arMultipleTransporters;
end;

function TArmy.AddUnits(Units: TUnitList): Boolean;
var I: Integer;
begin
  Result := CanAddUnits(Units) = arOK;
  if Result then
  begin
    BeginUpdate;
    for I := Units.GetCount - 1 downto 0 do AddUnit(Units.GetUnit(I));
    EndUpdate;
  end;
end;

function TArmy.CanAddUnitSelection(Units: TUnitList; Selection: Byte): TAddUnitsResult;
var List: TList; I, TransportCount: Integer; Transport: TAbstractUnit;
begin
  List := TList.Create;
  for I := 0 to Units.GetCount - 1 do
  begin
    if Selection and 1 <> 0 then List.Add(Units.GetUnit(I));
    Selection := Selection shr 1;
  end;
  TransportCount := 0;
  for I := 0 to List.Count - 1 do
    if TAbstractUnit(List[I]).GetTransporter then Inc(TransportCount);
  if IndexOfTransporter($FF) <> -1 then Inc(TransportCount);
  if TransportCount <= 1 then
  begin
  if TransportCount = 1 then
  begin
    Transport := Transporter($FF);
    if Transport = nil then
      for I := 0 to List.Count - 1 do
        if TAbstractUnit(List[I]).GetTransporter then Transport := TAbstractUnit(List[I]);
    if List.Count + GetCount <= Transport.GetTransportCapacity + 1 then Result := arOK
    else Result := arTooManyUnits;
  end
  else if List.Count + GetCount <= 8 then
  begin
    I := 0;
    while (I <> List.Count) and CanAddUnit(TAbstractUnit(List[I])) do Inc(I);
    if I <> List.Count then Result := arInvalidMoveType else Result := arOK;
  end
  else Result := arTooManyUnits;
  end
  else Result := arMultipleTransporters;
  List.Free;
end;

function TArmy.AddUnitSelection(Units: TUnitList; Selection: Byte): TAddUnitsResult;
var I: Integer; List: TUnitUserList;
begin
  Result := CanAddUnitSelection(Units, Selection);
  if Result = arOK then
  begin
    Units.BeginUpdate;
    List := TUnitUserList.Create(nil);
    for I := Units.GetCount - 1 downto 0 do
      if (1 shl I) and Selection <> 0 then
        if not Units.GetUnit(I).GetTransporter then List.AddUnit(Units.GetUnit(I))
        else AddUnit(Units.GetUnit(I));
    for I := List.GetCount - 1 downto 0 do AddUnit(List.GetUnit(I));
    Units.EndUpdate;
    List.Free;
  end;
end;

function TArmy.CanDeleteUnit(AUnit: TAbstractUnit): Boolean;
begin
  if IndexOfTransporter($FF) <> -1 then
    if AUnit.GetTransporter and (UnitsInTransporter <> 0) then Result := False
    else Result := True
  else Result := True;
end;

function TArmy.RemoveChild(Child: TEObject): Integer;
begin
  BeginUpdate;
  with TAbstractUnit(Child) do AddRef;
  Result := inherited RemoveChild(Child);
  with TAbstractUnit(Child) do Release;
  EndUpdate;
end;

function TArmy.AddChild(Child: TEObject): Integer;
begin
  if not (asActivated in FStatus) or TAbstractUnit(Child).CanActivate then
  begin
    Result := inherited AddChild(Child);
    if Result <> -1 then
    begin
      if (asActivated in FStatus) and not (usActivated in TAbstractUnit(Child).FUnitStatus) then
        TAbstractUnit(Child).Activate;
      TAbstractUnit(Child).SetPlayer(FPlayer);
    end;
  end
  else Result := -1;
end;

function TArmy.AddUnit(AUnit: TAbstractUnit): Boolean;
begin
  AUnit.SetOwner(Self);
  Result := Self = AUnit.Owner;
end;

procedure TArmy.GetLocation(var Xhx, Yhx, Lhx: Shortint);
begin
  if asActivated in FStatus then
  begin Xhx := FX; Yhx := FY; Lhx := FL; end
  else begin Xhx := -1; Yhx := -1; Lhx := -1; end;
end;

function TArmy.SelectionUnit(Selection: Byte; Index: Integer): TAbstractUnit;
var I: Integer;
begin
  Result := nil;
  I := 0;
  while (I <> FChildren.Count) and (Result = nil) do
  begin
    if Selection and 1 <> 0 then
    begin
      if Index = 0 then Result := TAbstractUnit(FChildren.List^[I]);
      Dec(Index);
    end;
    Selection := Selection shr 1;
    Inc(I);
  end;
end;

procedure TArmy.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FPlayer), 4);
  Stream.rwByte(Byte(FX), 5);
  Stream.rwByte(Byte(FY), 6);
  Stream.rwByte(Byte(FL), 7);
  if not (smWrite in Stream.StorageMode) or (AoWHSMap = nil) or
    (AoWHSMap.FConnectionType <> TPlayerConnectionType(1)) then
  begin
    Stream.rwByte(Byte(FDestinationX), 8);
    Stream.rwByte(Byte(FDestinationY), 9);
    Stream.rwByte(Byte(FDestinationL), 10);
    Stream.rwData(FUserMode, SizeOf(FUserMode), 13);
  end;
  Stream.rwData(FOldAIBehavior, SizeOf(FOldAIBehavior), 11);
  Stream.rwData(FMode, SizeOf(FMode), 12);
  if (smRead in Stream.StorageMode) and (amMoving in FMode) then
    FMode := FMode - [amMoving];
end;

procedure TArmy.MakeIndependent(Selection: Byte; var Armies: TArmyHSList);
var X, Y, L: Shortint; GoodArmy, EvilArmy: TArmy; Races, Units: TList;
  I, J, Race: Integer; AUnit: TAbstractUnit; Alignment: TAlignment; ArmyHS: TArmyHS;
  function PlaceIndependentArmy(AX, AY, AL: Shortint; Army: TArmy): TArmyHS;
  begin
    try
      if Army.GetCount <> 0 then
      begin
        Result := TArmyHS.Create(nil);
        Result.FArmy.BeginUpdate;
        Result.FArmy.AddUnits(Army);
        if Result.PlaceEx(X, Y, L, [apSafe, apScanArea]) then
        begin
          Result.Activate;
          Result.FArmy.EndUpdate;
        end
        else
        begin
          Result.FArmy.Kill($FF);
          Result.Free;
          Result := nil;
        end;
      end
      else Result := nil;
    except
      { Original suppresses placement failures without releasing a partly built army. }
      Result := nil;
    end;
  end;
begin
  BeginUpdate;
  GoodArmy := nil;
  EvilArmy := nil;
  Races := TList.Create;
  Units := TList.Create;
  for I := 0 to FChildren.Count - 1 do
  begin
    if Selection and 1 <> 0 then Units.Add(FChildren.List^[I]);
    Selection := Selection shr 1;
  end;
  for I := Units.Count - 1 downto 0 do
  begin
    AUnit := TAbstractUnit(Units.List^[I]);
    if (AUnit.GetRace <> -1) and not AUnit.GetAbilityEnabled($6B) then
    begin
      if AUnit.GetRace >= Races.Count then Races.Count := AUnit.GetRace + 1;
      if Races.List^[AUnit.GetRace] = nil then Races.List^[AUnit.GetRace] := TArmy.Create(nil);
      TArmy(Races.List^[AUnit.GetRace]).AddUnit(AUnit);
      Units.Delete(I);
    end;
  end;
  for I := Units.Count - 1 downto 0 do
  begin
    AUnit := TAbstractUnit(Units.List^[I]);
    Alignment := AUnit.GetAlignment;
    Race := -1;
    for J := Races.Count - 1 downto 0 do
      if (Races.List^[J] <> nil) and
        (Alignment in AoWHSSet.FRaceResources.GetRaceResource(J).FAlignments) then
        { Original chooses the largest compatible race group. }
        if (Race = -1) or (TArmy(Races.List^[Race]).GetCount <= TArmy(Races.List^[J]).GetCount) then Race := J;
    if Race <> -1 then
    begin
      TArmy(Races.List^[Race]).AddUnit(AUnit);
      Units.Delete(I);
    end
    else if (Alignment in alsGood) and
      (not (Alignment in alsEvil) or ((GoodArmy <> nil) and (EvilArmy = nil)) or
      ((GoodArmy = nil) and (EvilArmy = nil)) or
      ((GoodArmy <> nil) and (EvilArmy <> nil) and (GoodArmy.GetCount >= EvilArmy.GetCount))) then
    begin
      if GoodArmy = nil then GoodArmy := TArmy.Create(nil);
      GoodArmy.AddUnit(AUnit);
      Units.Delete(I);
    end
    else
    begin
      if EvilArmy = nil then EvilArmy := TArmy.Create(nil);
      EvilArmy.AddUnit(AUnit);
      Units.Delete(I);
    end;
  end;
  X := FX;
  Y := FY;
  L := FL;
  EndUpdate;
  for I := 0 to Races.Count - 1 do
    if Races.List^[I] <> nil then
    begin
      ArmyHS := PlaceIndependentArmy(X, Y, L, TArmy(Races.List^[I]));
      if (Armies <> nil) and (ArmyHS <> nil) then Armies.AddChild(ArmyHS);
      TArmy(Races.List^[I]).Free;
      Races.List^[I] := nil;
    end;
  if GoodArmy <> nil then
  begin
    ArmyHS := PlaceIndependentArmy(X, Y, L, GoodArmy);
    if (Armies <> nil) and (ArmyHS <> nil) then Armies.AddChild(ArmyHS);
    GoodArmy.Free;
  end;
  if EvilArmy <> nil then
  begin
    ArmyHS := PlaceIndependentArmy(X, Y, L, EvilArmy);
    if (Armies <> nil) and (ArmyHS <> nil) then Armies.AddChild(ArmyHS);
    EvilArmy.Free;
  end;
  Units.Free;
  Races.Free;
end;

procedure TArmy.UpdateIndependentRelation;
var Race: Shortint; Valid, Evil, Good, Neutral: Boolean; I, UnitRace: Integer;
  AUnit: TAbstractUnit; Alignment: TAlignment;
begin
  if FPlayer = 0 then
  begin
    Race := -1;
    Valid := True;
    I := FChildren.Count;
    while Valid and (I <> 0) do
    begin
      Dec(I);
      if not TAbstractUnit(FChildren.List^[I]).GetAbilityEnabled($6B) then
        UnitRace := TAbstractUnit(FChildren.List^[I]).GetRace
      else UnitRace := -1;
      if (UnitRace <> -1) and (UnitRace <> Race) then
        if Race = -1 then Race := UnitRace else Valid := False;
    end;
    if Valid and (Race = -1) then
    begin
      if FX <> -1 then
      begin
        Race := FIndependentRelation;
        FIndependentRelation := -1;
        FIndependentRelation := TAoWMapField(AoWHSMap.MapContainer.GetField(FX, FY, FL)).GetIndependentRelation;
        if FIndependentRelation >= 0 then Race := FIndependentRelation
        else begin FIndependentRelation := Race; Race := -1; end;
      end;
      if Race = -1 then
        if FIndependentRelation >= 0 then Race := FIndependentRelation else Valid := False;
    end;
    I := FChildren.Count;
    while Valid and (I <> 0) do
    begin
      Dec(I);
      Valid := (Race = TAbstractUnit(FChildren.List^[I]).GetRace) or
        (TAbstractUnit(FChildren.List^[I]).GetAlignment in AoWHSSet.FRaceResources.GetRaceResource(Race).FAlignments);
    end;
    if not Valid then
    begin
      Evil := True;
      Good := True;
      Neutral := True;
      for I := 0 to FChildren.Count - 1 do
      begin
        AUnit := TAbstractUnit(FChildren.List^[I]);
        Alignment := AUnit.GetAlignment;
        Evil := Evil and (Alignment in alsEvil) and
          ((AUnit.GetRace = -1) or (Alignment in [alEvil, alPureEvil]));
        Good := Good and (Alignment in alsGood) and
          ((AUnit.GetRace = -1) or (Alignment in [alPureGood, alGood]));
        Neutral := Neutral and (Alignment in alsNeutral);
      end;
      if Good and not Evil then FIndependentRelation := -2
      else if Evil and not Good then FIndependentRelation := -4
      else FIndependentRelation := -3;
    end
    else FIndependentRelation := Race;
  end
  else FIndependentRelation := -1;
end;

resourcestring
  DesertionRStr = 'Desertion';
  TheLeaderOfThePartyStepsForwardRStr = 'The leader of the party steps forward';
  OneUnitDesertedRStr = '1 unit deserted';
  XUnitsDesertedRStr = '%s units deserted';
  DesertUnitNoUpkeepRStr = 'This one abandons you, refusing a voucher for pay.';
  DesertUnitsNoUpkeepRStr = 'Without sufficient funds for support, these troops desert you.';
  DesertUnitLowMoraleRStr = 'With no common cause, this one deserts you.';
  DesertUnitsLowMoraleRStr = 'No longer sharing your cause, these desert you.';
  DesertUnitLowMoraleSplitRStr = 'Lacking faith, this one abandons your ranks';
  DesertUnitsLowMoraleSplitRStr = 'Troubled and weary, these abandon your ranks.';

procedure TArmy.Desert(Selection: Byte);
var Units: TList; Player: Shortint; Armies: TArmyHSList; Count, I, Bit: Integer;
  Log: TArmyInfoEventLog; AUnit: TAbstractUnit;
begin
  AoWHSMap.LockGameOverEvent;
  Units := TList.Create;
  Count := SelectionCount(Selection);
  Log := TArmyInfoEventLog.Create(nil);
  Log.FArmyView.Setup(Self, $FF);
  Log.FSelection := Selection;
  Log.FPlayer := FPlayer;
  Log.FTitle := TranslateRStr(DesertionRStr);
  Log.FTriggers := [etUser];
  if (AoWHSMap.FPlayMode = pmTurn) and (wpRebellion in AoWEngine.FRegistry.GetClassicWindowPopupEvents) then
  begin
    Log.FTriggers := Log.FTriggers + [etEvent];
    if AoWHSMap.FRequestCombatType then Log.FTriggers := Log.FTriggers + [etNewTurn];
  end;
  if (AoWHSMap.FPlayMode = pmSimultaneous) and (wpRebellion in AoWEngine.FRegistry.GetSimultaneousWindowPopupEvents) then
    Log.FTriggers := Log.FTriggers + [etEvent, etNewTurn];
  Log.FDescription := TranslateRStr(TheLeaderOfThePartyStepsForwardRStr);
  if Count = 1 then Log.FText := TranslateRStr(OneUnitDesertedRStr)
  else Log.FText := Format(TranslateRStr(XUnitsDesertedRStr), [IntToStr(Count)]);
  if (AoWHSMap.FPlayers.GetPlayers(FPlayer).FGems = 0) and
    (AoWHSMap.FPlayers.GetPlayers(FPlayer).GetUpkeep > AoWHSMap.FPlayers.GetPlayers(FPlayer).FIncome) then
    if Count = 1 then Log.FMessages.Text := TranslateRStr(DesertUnitNoUpkeepRStr)
    else Log.FMessages.Text := TranslateRStr(DesertUnitsNoUpkeepRStr)
  else if ValidateSelection($FF) = Selection then
    if Count = 1 then Log.FMessages.Text := TranslateRStr(DesertUnitLowMoraleRStr)
    else Log.FMessages.Text := TranslateRStr(DesertUnitsLowMoraleRStr)
  else if Count = 1 then Log.FMessages.Text := TranslateRStr(DesertUnitLowMoraleSplitRStr)
  else Log.FMessages.Text := TranslateRStr(DesertUnitsLowMoraleSplitRStr);
  DistributeLocationEventLog(Log, -1, FX, FY, FL, True);
  Log.Release;
  for I := GetCount - 1 downto 0 do
  begin
    Bit := 1 shl I;
    if (Bit and Selection <> 0) and GetUnit(I).GetAbilityEnabled($9B) then
    begin
      Units.Add(GetUnit(I));
      Selection := Selection and not Byte(Bit);
    end;
  end;
  Armies := TArmyHSList.Create(nil);
  Player := FPlayer;
  MakeIndependent(Selection, Armies);
  while Units.Count <> 0 do
  begin
    AUnit := TAbstractUnit(Units[0]);
    AUnit.AddRef;
    AUnit.Killed;
    AUnit.SetOwner(nil);
    AUnit.Release;
    Units.Delete(0);
  end;
  for I := 0 to Armies.GetCount - 1 do
    if DiplomaticRelation(0, Armies.GetArmyHS(I).FArmy.FIndependentRelation, Player, 0) = drWar then
      Armies.GetArmyHS(I).FArmy.SetBehavior($FF, gbRaid)
    else Armies.GetArmyHS(I).FArmy.SetBehavior($FF, gbScout);
  Armies.Free;
  Units.Free;
  AoWHSMap.UnlockGameOverEvent;
end;

function TArmy.GetPartyStatus(Selection: Byte): TPartyStatus;
var I, Morale, Count: Integer; Predictor: TCombatPredictor; UnitMorale: Integer; AUnit: TAbstractUnit;
begin
  Morale := 100;
  Count := 0;
  Predictor := TCombatPredictor.Create;
  for I := 0 to FChildren.Count - 1 do
  begin
    if Selection and 1 <> 0 then
    begin
      AUnit := TAbstractUnit(FChildren.List^[I]);
      UnitMorale := AUnit.FMoraleValue;
      if AUnit.GetUnitType <> utMachine then
      begin
        if UnitMorale < Morale then Morale := UnitMorale;
        Inc(Count);
      end;
      if UnitMorale <= 40 then Predictor.AddOpponent(AUnit, 0)
      else Predictor.AddUnit(AUnit);
    end;
    Selection := Selection shr 1;
  end;
  if Predictor.Execute = crDefeat then
    if Predictor.GetSuperiority < 50 then Result := psUnruly else Result := psUnrest
  else if (Count = 0) or (Morale <= 60) then Result := psStable
  else if Morale <= 80 then Result := psContent
  else Result := psCheerful;
  Predictor.Free;
end;

procedure TArmy.UpdateDesertion;
var Status: TPartyStatus; Chance, I: Integer; Selection: Byte;
begin
  if (FX <> -1) and (FPlayer <> 0) then
  begin
    Status := GetPartyStatus($FF);
    if Status in [psUnruly, psUnrest] then
    begin
      if Status = psUnrest then Chance := 10 else Chance := 50;
      if Chance > AoWHSMap.Random(100) then
      begin
        Selection := 0;
        for I := FChildren.Count - 1 downto 0 do
        begin
          Selection := Selection shl 1;
          if Smallint(TAbstractUnit(FChildren.List^[I]).FMoraleValue) <= 40 then Selection := Selection or 1;
        end;
        if Selection <> 0 then Desert(Selection);
      end;
    end;
  end;
end;

function TArmy.ValidateCrusaders: Boolean;
var I: Integer;
begin
  I := GetCount;
  Result := False;
  while (I <> 0) and not Result do
  begin
    Dec(I);
    if TAbstractUnit(FChildren.List^[I]).GetAbilityEnabled($65) then Result := True;
  end;
  if Result then
  begin
    BeginUpdate;
    for I := GetCount - 1 downto 0 do
      if TAbstractUnit(FChildren.List^[I]).GetAbilityEnabled($65) then
        TAbstractUnit(FChildren.List^[I]).ValidateCrusader;
    Result := GetCount <> 0;
    EndUpdate;
  end
  else Result := True;
end;

procedure TArmy.NewTurn(Player: Shortint);
begin
  if Player = FPlayer then
  begin
    FUserMode := FUserMode - [aumTurnDone];
    if ValidateCrusaders then UpdateDesertion;
  end;
end;

procedure TArmy.NewTurnDone(Player: Shortint);
begin
  if Player = FPlayer then
    if AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerType <> ptHuman then UpdateGroupBehavior;
end;

procedure TArmy.NewDay;
begin
  if AoWHSMap.FDay = 1 then
  begin
    ResetDestinationPos;
    if (FX <> -1) and (FPlayer > 0) then
    begin
      AoWHSMap.ExploreArea(FX, FY, FL, FPlayer, VisibilityRange);
      AoWHSMap.UpdatePlayerSeen(FPlayer, FX, FY, FL, VisibilityRange, TrueVisionRange);
    end;
    InitializeGroupBehavior;
  end;
end;

procedure TArmy.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  if Msg.MsgID = $20020003 then NewTurnDone(Msg.Value);
  if Msg.MsgID = $20020002 then LockChanged;
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20020002 then UnlockChanged;
  if Msg.MsgID = $20020005 then SetPlayer(FPlayer)
  else if (Msg.MsgID = $20020006) and (AoWHSMap.FSeatedPlayer <> -1) then
  begin
    UpdateUnfog;
    UpdateConcealment;
  end
  else if Msg.MsgID = $20020008 then
  begin
    UpdateVisibilityRanges;
    UpdateExploration;
    if AoWHSMap.FSeatedPlayer <> -1 then
    begin UpdateUnfog; UpdateConcealment; end;
  end
  else if Msg.MsgID = $20020002 then NewTurn(Msg.Value)
  else if Msg.MsgID = $20020001 then NewDay
  else if (Msg.MsgID = $20020003) and (Msg.Value = FPlayer) then ValidateCrusaders;
end;

resourcestring
  P2PartyJoinHeaderRStr = 'The leader of the party steps forward:';
  P2PartyJoinRStr = 'Party Join';
  P2OneUnitJoinedRStr = '1 unit joined';
  P2AUnitJoinedTheForcesofYRStr = 'A unit joined the forces of %s';
  P2XUnitsJoinedRStr = '%s units joined';
  P2XUnitsJoinedTheForcesofYRStr = '%d units joined the forces of %s';
  P2XJoinedRStr = '%s joined';
  P2XJoinedTheForcesOfYRStr = '%0:s joined the forces of %1:s';
  P2FireDamageRStr = 'Fire damage';
const
  P2StormNames: array[TStormType] of string =
    ('None', 'Fire', 'Death', 'Life', 'Ice', 'Lightning', 'Pestilence');

function TArmy.CanActivate: Boolean;
begin
  Result := True;
end;

function TArmy.GetMoveAction(Player: Shortint): TMoveAction;
begin
  Result := maNormal;
  if Player <> FPlayer then
  begin
    if AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType = ptHuman then
    begin
      if not (asFullyConcealed in FStatus) then
        if (FPlayer = 0) and (GetJoinSelection(Player) <> 0) then Result := maNegotiate
        else Result := maAttack;
    end
    else
      if (FPlayer = 0) and (GetJoinSelection(Player) <> 0) then Result := maNegotiate
      else Result := maAttack;
  end
  else Result := maCombine;
end;

function TArmy.GetCanJoinSelection(Player: Shortint): Byte;
var I: Integer; AUnit: TAbstractUnit;
begin
  if Player > 0 then
  begin
    Result := 0;
    for I := Count - 1 downto 0 do
    begin
      Result := Result shl 1;
      AUnit := TAbstractUnit(FChildren.List^[I]);
      if AUnit.CanJoin(Player) then Result := Result or 1;
    end;
    if IndexOfTransporter($FF) <> -1 then
      if Result <> ValidateSelection($FF) then Result := 0;
  end
  else Result := 0;
end;

function TArmy.GetJoinSelection(Player: Shortint): Byte;
var WantsJoin: Boolean; I: Integer;
begin
  Result := 0;
  if Player > 0 then
  begin
    WantsJoin := False;
    I := Count;
    while not WantsJoin and (I <> 0) do
    begin
      Dec(I);
      WantsJoin := TAbstractUnit(FChildren.List^[I]).OfferToJoin(Player);
    end;
    if WantsJoin then Result := GetCanJoinSelection(Player);
  end;
end;

function TArmy.JoinAmount(Player: Shortint; Selection: Byte): Integer;
var I: Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
  begin
    if Selection and 1 <> 0 then
      Inc(Result, TAbstractUnit(FChildren.List^[I]).JoinAmount(Player));
    Selection := Selection shr 1;
  end;
end;

function TArmy.IncommingNegotiateRequest(Log: TNegotiateRequestEventLog): Boolean;
begin
  Result := False;
  if FPlayer = 0 then
  begin
    Log.SetupJoinArmy(Self, Log.FPlayer, jmDefault);
    Log.FObject := noArmy;
    Log.FText := TranslateRStr(P2PartyJoinHeaderRStr);
    Result := Log.FSelection <> 0;
  end;
end;

function TArmy.IncommingNegotiateOffer(Offer: TNegotiateTE): Boolean;
var
  Log: TArmyInfoEventLog;
  Selection: Byte;
  AHero: THero;
  Locations: TXYLList;
  I, J, Direction, X, Y, JoinCount: Integer;
  Placed: Boolean;
begin
  if Offer.FObject = noArmy then
  begin
    if Offer.FResult = nrAccept then
    begin
      Selection := GetJoinSelection(Offer.FPlayer);
      JoinCount := SelectionCount(Selection);
      if (nmPrisonerJoin in Offer.FMode) or (JoinAmount(Offer.FPlayer, Selection) <= Offer.FGold) then
      begin
        BeginUpdate;
        Offer.FMode := Offer.FMode + [nmMoveOnAccept];
        Log := TArmyInfoEventLog.Create(nil);
        Log.FArmyView.Setup(Self, Selection);
        Log.FSelection := $FF;
        Log.FDescription := '';
        Log.FTitle := TranslateRStr(P2PartyJoinRStr);
        Log.FTriggers := [etEvent];
        AHero := Hero(Selection, [htHero]);
        if AHero = nil then
        begin
          if JoinCount = 1 then
          begin
            Log.FText := TranslateRStr(P2OneUnitJoinedRStr);
            Log.FMessages.Add(Format(TranslateRStr(P2AUnitJoinedTheForcesofYRStr),
              [AoWHSMap.FPlayers.GetPlayers(Offer.FPlayer).GetName]));
          end
          else
          begin
            Log.FText := Format(TranslateRStr(P2XUnitsJoinedRStr), [IntToStr(JoinCount)]);
            Log.FMessages.Add(Format(TranslateRStr(P2XUnitsJoinedTheForcesofYRStr),
              [SelectionCount(Selection), AoWHSMap.FPlayers.GetPlayers(Offer.FPlayer).GetName]));
          end;
        end
        else
        begin
          Log.FText := Format(TranslateRStr(P2XJoinedRStr), [AHero.FHeroName]);
          Log.FMessages.Add(Format(TranslateRStr(P2XJoinedTheForcesOfYRStr),
            [AHero.FHeroName, AoWHSMap.FPlayers.GetPlayers(Offer.FPlayer).GetName]));
        end;
        DistributeLocationEventLog(Log, -1, FX, FY, FL, False);
        Log.Release;
        if ValidateSelection($FF) <> Selection then
        begin
          Locations := TXYLList.Create;
          if Offer.FArmyHS <> nil then
          begin
            Direction := dHXtoHNfast(FX, FY, Offer.FArmyHS.GetXhx, Offer.FArmyHS.GetYhx);
            if (Direction > 0) and (Direction <= 6) then
            begin
              Locations.AddXYL(FX, FY, FL);
              J := Direction + 1;
              if J > 6 then J := 1;
              CenterHNtoHX(Offer.FX, Offer.FY, J, X, Y);
              Locations.AddXYL(X, Y, FL);
              Dec(Direction);
              if Direction = 0 then Direction := 6;
              CenterHNtoHX(Offer.FX, Offer.FY, Direction, X, Y);
              Locations.AddXYL(X, Y, FL);
            end;
          end;
          J := 0;
          I := Count;
          while I <> 0 do
          begin
            Dec(I);
            if (Selection and (1 shl I)) <> 0 then
            begin
              Placed := False;
              while not Placed and (J < Locations.Count) do
              begin
                Placed := GetUnit(I).Place(Locations[J].X, Locations[J].Y, Locations[J].L,
                  Offer.FPlayer, []) <> nil;
                if not Placed then Inc(J);
              end;
              if not Placed then GetUnit(I).Place(FX, FY, FL, Offer.FPlayer, [pmScanArea]);
            end;
          end;
          Locations.Free;
        end
        else SetPlayer(Offer.FPlayer);
        EndUpdate;
        Offer.Accept;
      end
      else
      begin
        Offer.FMode := [nmAttackOnReject];
        Offer.Reject;
      end;
    end
    else if (Offer.FResult = nrReject) and not (nmPrisonerJoin in Offer.FMode) then Offer.Reject;
    Result := True;
  end
  else Result := False;
end;

procedure TArmy.TriggerFireDamage;
var Log: TArmyEventLog; AUnit: TAbstractUnit; Damage, I: Integer; Damaged: Boolean;
begin
  RandSeed := AoWHSMap.Random($FFFFFF);
  Log := TArmyEventLog.Create(nil);
  Log.FArmyText := TranslateRStr(P2FireDamageRStr);
  Log.FPlayer := GetArmyHS.FArmy.FPlayer;
  Log.FArmyMessages.Add(TranslateRStr(P2FireDamageRStr));
  Log.FArmyIcon := 0;
  Log.FArmyView.Setup(GetArmyHS.FArmy, $FF);
  BeginUpdate;
  Damaged := False;
  for I := 0 to Count - 1 do
  begin
    AUnit := GetUnit(I);
    if not (dtFire in AUnit.GetImmunityTypes) then
    begin
      Damage := AUnit.ExecuteDamageRole(4, 4, [dtFire]);
      if Damage > AUnit.GetHitPoints then Damage := AUnit.GetHitPoints;
      if Damage <> 0 then
      begin
        Damaged := True;
        AUnit.SetHitPoints(AUnit.GetHitPoints - Shortint(Damage));
      end;
      Log.FDamageValues.Add(Damage);
      Log.FDamageTypes.Add(Ord(dtFire));
    end
    else
    begin
      Log.FDamageValues.Add(0);
      Log.FDamageTypes.Add(Ord(dtNone));
    end;
  end;
  Log.ValidateGameOver;
  if Damaged then DistributeLocationEventLog(Log, -1, FX, FY, FL, True);
  Log.Release;
  Validate;
  EndUpdate;
end;

procedure TArmy.RetrieveStormDamageInfo(Storm: TStormType; Distance: Integer; var Info: TStormDamageInfo);
var I, Attack, Damage, Value, Amount: Integer; AUnit: TAbstractUnit; Relation: TDiplomaticRelation;
begin
  Relation := DiplomaticRelation(Info.Player, Info.IndependentRelation, FPlayer, FIndependentRelation);
  if (Ord(Relation) in Info.FriendlyRelations) or (Ord(Relation) in Info.EnemyRelations) then
  begin
    case Storm of
      stIce: begin Attack := 7; Damage := 5; end;
      stLightning: begin Attack := 8; Damage := 7; end;
      stDeath: begin Attack := 7; Damage := 4; end;
      stHoly: begin Attack := 7; Damage := 5; end;
      stFire: begin Attack := 7; Damage := 5; end;
      stPestilence: begin Attack := 4; Damage := 3; end;
    else Attack := 0; Damage := 0;
    end;
    for I := Count - 1 downto 0 do
    begin
      AUnit := GetUnit(I);
      if (AUnit.FPlayer <> 0) or ((AUnit.FGroup <> nil) and (AUnit.FGroup.Behavior <> gbRefuge)) then
      begin
        AUnit.RetrieveDamageInfo(Attack, Damage, [P2StormDamageType[Storm]], Value, Amount);
        if Ord(Relation) in Info.FriendlyRelations then
        begin Inc(Info.FriendlyDamage, Value); Inc(Info.FriendlyValue, Amount); end;
        if Ord(Relation) in Info.EnemyRelations then
        begin Inc(Info.EnemyDamage, Value); Inc(Info.EnemyValue, Amount); end;
      end;
    end;
  end;
end;

procedure TArmy.IncommingStorm(A1: TStormType; A2: Integer; A3: Shortint);
var Log: TArmyEventLog; I, Damage: Integer; Damaged: Boolean;
begin
  RandSeed := AoWHSMap.Random($FFFFFF);
  Log := TArmyEventLog.Create(nil);
  Log.FArmyText := TranslateRStr(P2StormNames[A1]);
  Log.FPlayer := A3;
  Log.FArmyMessages.Text := TranslateRStr(P2StormNames[A1]);
  Log.FArmyIcon := 2;
  Log.FArmyView.Setup(Self, $FF);
  BeginUpdate;
  Damaged := False;
  for I := 0 to Count - 1 do
  begin
    Damage := TAbstractUnit(FChildren.List^[I]).ExecuteStormDamage(A1);
    if Damage <> 0 then Damaged := True;
    Log.FDamageValues.Add(Damage);
    Log.FDamageTypes.Add(Ord(P2StormDamageType[A1]));
  end;
  if Damaged then
  begin
    Log.ValidateGameOver;
    DistributeLocationEventLog(Log, FPlayer, FX, FY, FL, True);
  end;
  Log.Release;
  Validate;
  EndUpdate;
end;

procedure TArmy.UpdateAITarget(const Info: TAITargetInfo; var Data: TAITargetData);
var Selection: Byte;
begin
  case Info.Mode of
    tmAttack, tmRaid, tmAttackArmies:
      if not GetUnitsConcealedForPlayer($FF, Info.Player) and (Info.Player <> FPlayer) then
      begin
        if FPlayer > 0 then
        begin
          if ValidAttackRelation(Info.Player, Info.IndependentRelation, FPlayer, FIndependentRelation) or (Info.Mode = tmRaid) then
            if (Info.Player <> 0) and (Leader($FF) <> nil) then Data.Priority := 300
            else if (Info.Player <> 0) and (Hero($FF, [htHero]) <> nil) then Data.Priority := 100
            else Data.Priority := 50
          else Data.Priority := 0;
        end
        else if FPlayer = 0 then
        begin
          Selection := GetJoinSelection(Info.Player);
          if Selection <> 0 then
          begin
            Data.Cost := JoinAmount(Info.Player, Selection);
            Data.TargetType := attNegotiate;
          end
          else if ValidAttackRelation(Info.Player, Info.IndependentRelation, FPlayer, FIndependentRelation) then
            Data.Priority := 50;
        end;
      end;
    tmGuardArea:
      if not GetUnitsConcealedForPlayer($FF, Info.Player) and (Info.Player <> FPlayer) then Data.Priority := 50
      else Data.Priority := 0;
    tmHunt: Data.Priority := 10;
    tmRecruit:
      if (Info.Player = FPlayer) and ((FPlayer <> 0) or
        (DiplomaticRelation(Info.Player, Info.IndependentRelation, FPlayer, FIndependentRelation) <> drWar)) then
        Data.Priority := Data.Priority or 1;
  end;
end;

function TArmy.AIMovePriority: Integer;
begin
  Result := 0;
  if Leader($FF) <> nil then Inc(Result, 50000);
  if Hero($FF, [htHero, htHeroLeader]) <> nil then Inc(Result, 10000);
  Inc(Result, ObtainValue($FF));
end;

procedure TArmy.ResetMoveDone;
var I: Integer; AUnit: TAbstractUnit;
begin
  for I := FChildren.Count - 1 downto 0 do
  begin
    AUnit := TAbstractUnit(FChildren.List^[I]);
    AUnit.FUnitStatus := AUnit.FUnitStatus - [usMoveDone];
  end;
end;

function TArmy.CanCombine(Army: TArmy; Selection: Byte): Boolean;
var I, MaxCount: Integer; Temp: Byte; OwnTransporter, OtherTransporter: TAbstractUnit;
begin
  Selection := Army.ValidateSelection(Selection);
  I := 0;
  Temp := Selection;
  while Temp <> 0 do
  begin
    if Temp and 1 <> 0 then Inc(I);
    Temp := Temp shr 1;
  end;
  OwnTransporter := Transporter($FF);
  if OwnTransporter <> nil then MaxCount := OwnTransporter.GetTransportCapacity + 1
  else MaxCount := 8;
  Inc(I, Count);
  if I <= MaxCount then
  begin
    OtherTransporter := Army.Transporter(Selection);
    if (OtherTransporter <> nil) and ((I > OtherTransporter.GetTransportCapacity + 1) or (OwnTransporter <> nil)) then
      Result := False
    else Result := True;
  end
  else Result := False;
end;

resourcestring
  P2ArmyRStr = 'Army';

constructor TArmyHS.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FArmy := TArmy.Create(nil);
end;

destructor TArmyHS.Destroy;
begin
  FArmy.FOnUpdate := nil;
  inherited Destroy;
  FArmy.Free;
  FArmy := nil;
end;

class function TArmyHS.ClassID: Integer;
begin
  Result := $20217;
end;

function TArmyHS.GetFogEnabled: Boolean;
begin
  Result := (AoWHSMap.FFogEnabled <> 0) and
    (WordRec(LongRec(TAoWMapField(Owner).FFieldFlags).Hi).Lo = 0);
end;

function TArmyHS.VisibleForSeatedPlayer: Boolean;
begin
  Result := ((AoWHSMap.FFogEnabled = 0) or
    (WordRec(LongRec(TAoWMapField(Owner).FFieldFlags).Hi).Lo <> 0)) and not FArmy.GetFullyConcealed;
end;

function TArmyHS.EditName: string;
begin
  Result := TranslateRStr(P2ArmyRStr);
end;

procedure TArmyHS.Clear;
begin
  inherited Clear;
  FArmy.Clear;
end;

function TArmyHS.PlaceOnMap: Boolean;
var Msg: TMapFieldMsg;
begin
  Result := inherited PlaceOnMap;
  if Result then
  begin
    FArmy.BeginUpdate;
    with TMapField(Owner) do FArmy.SetXYL(Xhx, Yhx, Lhx);
    FArmy.UpdateUnfog;
    FArmy.UpdateExploration;
    Msg.MsgID := $1102;
    Msg.Param[0] := Integer(Self);
    TMapField(Owner).SendMapFieldMsg(Msg);
    FArmy.EndUpdate;
  end;
end;

procedure TArmyHS.RemoveFromMap;
var Field: TMapField; Msg: TMapFieldMsg;
begin
  Field := TMapField(Owner);
  if Field <> nil then FArmy.TurnUnFogOff;
  inherited RemoveFromMap;
  if (Field <> nil) and (AoWHSMap <> nil) and not (msDestroying in AoWHSMap.Status) then
  begin
    Msg.MsgID := $1103;
    Msg.Param[0] := Integer(Self);
    Field.SendMapFieldMsg(Msg);
  end;
end;

procedure TArmyHS.Select;
begin
  FArmy.Select;
  if Self <> AoWHSMap.FSelectedArmy.GetArmyHS then AoWHSMap.FSelectedArmy.SetArmyHS(Self);
end;

procedure TArmyHS.Unselect;
begin
  inherited Unselect;
  FArmy.Unselect;
  if Self = AoWHSMap.FSelectedArmy.GetArmyHS then AoWHSMap.FSelectedArmy.SetArmyHS(nil);
end;

function TArmyHS.CanSelect(Xhp, Yhp: Integer): Boolean;
begin
  Result := not GetFogEnabled and (AoWHSMap.FSeatedPlayer <> -1) and
    not (asFullyConcealed in FArmy.FStatus) and inherited CanSelect(Xhp, Yhp);
end;

function TArmyHS.GetSelected: Boolean;
begin
  Result := asSelected in FArmy.FStatus;
end;

procedure TArmyHS.ArmyUpdated(Sender: TObject);
var Msg: TMapFieldMsg;
begin
  if FArmy.Count <> 0 then
  begin
    Msg.MsgID := $1124;
    Msg.Param[0] := Integer(Self);
    TMapField(Owner).SendMapFieldMsg(Msg);
    UpdateUnitGFXResource;
    if FArmy.FPlayer <> 0 then FFlagID := AoWHSMap.FPlayers.GetPlayers(FArmy.FPlayer).FPlayerRace
    else FFlagID := $20;
  end
  else if Sender = FArmy then Destroy;
end;

procedure TArmyHS.UpdateFlagID;
begin
  if FArmy.FPlayer > 0 then
  begin
    FFlagID := AoWHSMap.FPlayers.GetPlayers(FArmy.FPlayer).FPlayerRace;
    Exit;
  end;
  FFlagID := $20;
end;

procedure TArmyHS.UpdateUnitGFXResource;
var I: Integer;
begin
  if asConcealed in FArmy.FStatus then
  begin
    I := 0;
    while ((FArmy.FConcealedUnits shr I) and 1) = 1 do Inc(I);
    if I >= FArmy.Count then I := 0;
  end
  else I := 0;
  FUnitIndex := I;
  SetUnitGFXResourceIndex(FArmy.GetUnit(I).GetUnitGFXResourceIndex);
  if mtFlying in FArmy.GetUnit(I).GetMoveTypes then FUnitYOffset := -8
  else FUnitYOffset := 0;
  Assert(FUnitGFXResource <> nil);
end;

procedure TArmyHS.Activate;
begin
  inherited Activate;
  FArmy.SetXYL(GetXhx, GetYhx, GetLhx);
  FArmy.Activate;
  FArmy.FOnUpdate := ArmyUpdated;
  if Self = TAoWMapField(Owner).GetArmyHS then
  begin
    if FArmy.Count <> 0 then UpdateUnitGFXResource
    else if not (msEditting in AoWHSMap.Status) then
    begin
      Destroy;
      Exit;
    end;
  end
  else Destroy;
end;

procedure TArmyHS.Deactivate;
begin
  inherited Deactivate;
  FArmy.Deactivate;
end;

procedure TArmyHS.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwEObject(FArmy, 10);
end;

function TArmyHS.CanChangeTerrain(const Info: HSEngine.THSSenderInfo): Boolean;
begin
  if Info.HN = 0 then
    Result := ((Info.MapField.TerrainType = 0) and (Info.Sender <> nil) and
      ((TEObject(Info.Sender).ClassID = $2123E) or (TEObject(Info.Sender).ClassID = $2016C))) or
      FArmy.ValidTerrain(Info.MapField.TerrainType, Info.MapField.OverlayType)
  else Result := True;
end;

procedure TArmyHS.TerrainChanged(const Info: HSEngine.THSTerrainInfo);
begin
  inherited TerrainChanged(Info);
  if (Info.HN = 0) and (asActivated in FArmy.FStatus) then
  begin
    FArmy.BeginUpdate;
    FArmy.ValidateTerrain(Info.TerrainType, Info.OverlayType);
    FArmy.EndUpdate;
  end;
end;

function TArmyHS.CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer;
begin
  if Info.HN = 0 then
  begin
    if not (mmAI in TMoveControl(Info.Sender).FMode) and
      (GetFogEnabled or (asFullyConcealed in FArmy.FStatus) or (mmIgnoreArmies in TMoveControl(Info.Sender).FMode)) then
    begin Result := 1; Exit; end;
    if FArmy.FPlayer = TMoveControl(Info.Sender).FPlayer then
    begin
      if not (mmAvoidArmies in TMoveControl(Info.Sender).FMode) or (Self = TMoveControl(Info.Sender).FTransporterArmy) then
      begin
        if FArmy.FPlayer = 0 then Result := 2
        else
        begin
          if (mmAI in TMoveControl(Info.Sender).FMode) and (FArmy.IndexOfTransporter($FF) <> -1) then
          begin Result := 2; Exit; end;
          if (TMoveControl(Info.Sender).FArmyHS <> nil) and
            FArmy.CanCombine(TMoveControl(Info.Sender).FArmyHS.FArmy, TMoveControl(Info.Sender).FSelection) then Result := 1
          else Result := 2;
        end;
      end
      else Result := 0;
    end
    else if AoWHSMap.FPlayers.GetDiplomaticRelation(TMoveControl(Info.Sender).FPlayer, FArmy.FPlayer) = drAlliance then
    begin
      if (Info.MapField.OverlayType = 7) and (Info.MapField.FindNoneTransparentHS(TPlayerStructure) <> nil) then
      begin Result := 0; Exit; end;
      Result := 2;
    end
    else Result := 0;
  end
  else Result := 1;
end;

procedure TArmyHS.CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult);
begin
  if Info.HN = 0 then
  begin
    if FArmy.FPlayer = TMoveControl(Info.Sender).FPlayer then
    begin
      if (mmSurround in TMoveControl(Info.Sender).FMode) and (Info.MoveOverCode <> 1) and
        (TMapField(Owner).Xhx = TMoveControl(Info.Sender).FDestinationX) and
        (TMapField(Owner).Yhx = TMoveControl(Info.Sender).FDestinationY) and
        (TMapField(Owner).Lhx = TMoveControl(Info.Sender).FDestinationL) and
        not FArmy.CanCombine(TMoveControl(Info.Sender).FArmyHS.FArmy, TMoveControl(Info.Sender).FSelection) then
      begin MoveResult.Code := -1; MoveResult.Done := True; Exit; end;
      if (TMoveControl(Info.Sender).FArmyHS <> nil) and (FArmy.IndexOfTransporter($FF) <> -1) and
        (TMoveControl(Info.Sender).FArmyHS.FArmy.Transporter(TMoveControl(Info.Sender).FSelection) = nil) then
      begin MoveResult.Code := 4; MoveResult.Done := True; end;
    end
    else if Info.MoveOverCode <> 1 then
    begin MoveResult.Code := -1; MoveResult.Done := True; end;
  end;
end;

procedure TArmyHS.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin
  if Info.HN = 0 then TAoWMapField(Info.MapField).FFieldFlags := TAoWMapField(Info.MapField).FFieldFlags or $0F007000;
end;

function TArmyHS.MoveTo(Field: TMapField; MoveCost: Integer): Boolean;
var OldField: TMapField; Msg: TMapFieldMsg;
begin
  FArmy.BeginUpdate;
  OldField := TMapField(Owner);
  if OldField <> nil then
  begin
    Msg.MsgID := $1140;
    Msg.Param[0] := Integer(Self);
    Msg.Param[1] := Integer(Field);
    Msg.Result := 0;
    OldField.SendMapFieldMsg(Msg);
  end;
  if (OldField = nil) or (Msg.Result = 0) then
  begin
    Msg.MsgID := $1141;
    Msg.Param[0] := Integer(Self);
    Msg.Param[1] := Integer(OldField);
    Msg.Result := 0;
    Field.SendMapFieldMsg(Msg);
    if Msg.Result = 0 then
    begin
      inherited MoveTo(Field, MoveCost);
      if (OldField <> nil) and ((Field.Lhx <> OldField.Lhx) or
        not ConnectingHX(OldField.Xhx, OldField.Yhx, Field.Xhx, Field.Yhx)) then
      begin
        AoWHSMap.NotifyPlayerChanged(OldField.Xhx, OldField.Yhx, OldField.Lhx);
        AoWHSMap.NotifyPlayerChanged(Field.Xhx, Field.Yhx, Field.Lhx);
      end
      else AoWHSMap.NotifyPlayerChangedEx(Field.Xhx, Field.Yhx, Field.Lhx, $D);
      FArmy.Validate;
      FArmy.MovedTo(OldField, Field, MoveCost);
      Msg.MsgID := $1142;
      Msg.Param[0] := Integer(Self);
      Msg.Param[1] := Integer(OldField);
      Msg.Result := 0;
      Field.SendMapFieldMsg(Msg);
      if FArmy.FPlayer > 0 then AoWHSMap.UpdatePlayerSeen(FArmy.FPlayer, Field.Xhx,
        Field.Yhx, Field.Lhx, FArmy.VisibilityRange, FArmy.TrueVisionRange);
      Result := True;
    end
    else Result := False;
  end
  else Result := False;
  FArmy.EndUpdate;
end;

function TArmyHS.PlaceHX(Map: TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
var Field: TMapField; Army: TEObject;
begin
  if FArmy.CanPlace(Xhx, Yhx, Lhx) then
  begin
    Field := Map.GetField(Xhx, Yhx, Lhx);
    Army := Field.FindOwnedChild($20217);
    if (Army = nil) or GetEditMode then Result := inherited PlaceHX(Map, Xhx, Yhx, Lhx)
    else Result := False;
  end
  else Result := False;
end;

function TArmyHS.PlacePrivate(Map: TMapContainer; X, Y, L: Shortint): Boolean;
begin
  Result := inherited PlaceHX(Map, X, Y, L);
  if Result then Activate;
end;

procedure TArmyHS.ShowShadow(X, Y: Integer; const SurfaceDesc: TSurfaceDesc);
var Sequence: TImageSequence; Xhp, Yhp, DX, DY: Integer; Part: Single;
begin
  if ((WordRec(LongRec(TAoWMapField(Owner).FFieldFlags).Hi).Lo <> 0) or (AoWHSMap.FFogEnabled = 0)) and
    not (asFullyConcealed in FArmy.FStatus) then
  begin
    HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhp, Yhp);
    X := Xhp - X;
    Y := Yhp - Y;
    if FMoveStep <> -1 then
    begin
      HNtoHP(FDirection, DX, DY);
      if FStatus and $10 = 0 then
      begin
        Part := FMoveStep / GetMoveSteps;
        Inc(X, Round(Part * DX));
        Inc(Y, Round(Part * DY));
      end;
    end;
    if FDirection = 0 then Sequence := FUnitGFXResource.FSequences.GetImageSequence(27)
    else Sequence := FUnitGFXResource.FSequences.GetImageSequence(FDirection + 23);
    while Sequence <> nil do
    begin
      Sequence.ImageLibrary[Sequence.GetFrameIndex(AoWHSMap.Frame, (Integer(Self) shr 2) and $FFFF)].Show(
        X + Sequence.dXshift, Y + Sequence.dYshift, SurfaceDesc);
      Sequence := Sequence.Next;
    end;
  end;
end;

procedure TArmyHS.PlayMoveSFX;
var Sequence: TImageSequence; Frame: Integer;
begin
  if (FMoveStep <> -1) and (FStatus and 8 = 0) then
  begin
    if FDirection = 0 then Sequence := FUnitGFXResource.FSequences.List^[9]
    else Sequence := FUnitGFXResource.FSequences.List^[FDirection + 5];
    if Sequence <> nil then
    begin
      Frame := Sequence.GetFrameIndex(AoWHSMap.Frame, (Integer(Self) shr 2) and $FFFF);
      if Sequence.SpeedCount = Sequence.SequenceSpeed then
        FUnitGFXResource.FSFXLibraries[1].Play(Frame mod 100);
    end;
  end;
end;

procedure TArmyHS.ShowEnchantments(X, Y: Integer; const SurfaceDesc: TSurfaceDesc);
var Info: TP2UnitShowInfo;
begin
  if FArmy.Count > FUnitIndex then
  begin
    Info.Overlays := [];
    Info.Animation := uaNone;
    Info.Frame := AoWHSMap.Frame + ((X + Y * 2) shr 4);
    Info.Looped := True;
    FArmy.GetUnit(FUnitIndex).ShowEx(X - 16, Y - 20, SurfaceDesc, Info);
  end;
end;

procedure TArmyHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var Sequence: TImageSequence; Frame, Xhp, Yhp, DX, DY: Integer; Part: Real;
begin
  if (WordRec(LongRec(TAoWMapField(Owner).FFieldFlags).Hi).Lo <> 0) or (AoWHSMap.FFogEnabled = 0) then
  begin
    Assert(FUnitGFXResource.FSequences.Count > FDirection, 'Invalid Unit Index');
    HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhp, Yhp);
    XhpSurf := Xhp - XhpSurf;
    YhpSurf := Yhp - YhpSurf;
    if FMoveStep = -1 then
      if FDirection = 0 then Sequence := FUnitGFXResource.FSequences.List^[3]
      else Sequence := FUnitGFXResource.FSequences.List^[FDirection - 1]
    else
    begin
      HNtoHP(FDirection, DX, DY);
      if FStatus and $10 = 0 then
      begin
        Part := FMoveStep / GetMoveSteps;
        Inc(XhpSurf, Round(Part * DX));
        Inc(YhpSurf, Round(Part * DY));
      end;
      if FStatus and 8 = 0 then
        if FDirection = 0 then Sequence := FUnitGFXResource.FSequences.List^[9]
        else Sequence := FUnitGFXResource.FSequences.List^[FDirection + 5]
      else
        if FDirection = 0 then Sequence := FUnitGFXResource.FSequences.List^[3]
        else Sequence := FUnitGFXResource.FSequences.List^[FDirection - 1];
    end;
    if not (asConcealed in FArmy.FStatus) then
    begin
      if not (msEditting in AoWHSMap.Status) and (AoWHSMap.FSeatedPlayer = FArmy.FPlayer) and
        (FArmy.Count = FArmy.ConcealedUnitsCount) then
      begin
        while Sequence <> nil do
        begin
          Frame := Sequence.GetFrameIndex(AoWHSMap.Frame, (Integer(Self) shr 2) and $FFFF);
          if Frame <> -1 then Sequence.ImageLibrary[Frame].Show(XhpSurf + Sequence.dXshift,
            YhpSurf + Sequence.dYshift + FUnitYOffset, SurfaceDesc);
          Sequence := Sequence.Next;
        end;
        ShowEnchantments(XhpSurf, YhpSurf + FUnitYOffset, SurfaceDesc);
        if asSelected in FArmy.FStatus then
        begin
          if AoWHSMap.Frame and 6 <> 6 then
            if FFlagID <> $20 then
            begin
              AoWHSSet.FRaceResources.GetRaceResource(FFlagID).FImageLibrary[FArmy.Count + 29].ShowBlended(
                XhpSurf - 5, YhpSurf - 12, SurfaceDesc, AlphaBlendTable.LookupTables[50]);
              if asShowCrown in FArmy.FStatus then AoWHSSet.FFlagControl.FFlags[FFlagID + 80].Show(
                XhpSurf - 5, YhpSurf - 14, SurfaceDesc);
            end
            else AoWHSSet.FFlagControl.FFlags[FArmy.Count + 39].ShowBlended(XhpSurf - 5, YhpSurf - 12,
              SurfaceDesc, AlphaBlendTable.LookupTables[50]);
        end
        else if FFlagID <> $20 then
        begin
          AoWHSSet.FRaceResources.GetRaceResource(FFlagID).FImageLibrary[FArmy.Count + 29].ShowBlended(
            XhpSurf - 5, YhpSurf - 12, SurfaceDesc, AlphaBlendTable.LookupTables[Abs((AoWHSMap.Frame shl 2) mod 60 - 30) + 40]);
          if asShowCrown in FArmy.FStatus then AoWHSSet.FFlagControl.FFlags[FFlagID + 80].Show(
            XhpSurf - 5, YhpSurf - 14, SurfaceDesc);
        end
        else AoWHSSet.FFlagControl.FFlags[FArmy.Count + 39].ShowBlended(XhpSurf - 5, YhpSurf - 12,
          SurfaceDesc, AlphaBlendTable.LookupTables[Abs((AoWHSMap.Frame shl 2) mod 60 - 30) + 40]);
      end
      else
      begin
        while Sequence <> nil do
        begin
          Frame := Sequence.GetFrameIndex(AoWHSMap.Frame, (Integer(Self) shr 2) and $FFFF);
          if Frame <> -1 then Sequence.ImageLibrary[Frame].Show(XhpSurf + Sequence.dXshift,
            YhpSurf + Sequence.dYshift + FUnitYOffset, SurfaceDesc);
          Sequence := Sequence.Next;
        end;
        ShowEnchantments(XhpSurf, YhpSurf + FUnitYOffset, SurfaceDesc);
        if not (asSelected in FArmy.FStatus) or (AoWHSMap.Frame and 6 <> 6) then
          if FFlagID = $20 then AoWHSSet.FFlagControl.FFlags[FArmy.Count + 39].Show(XhpSurf - 5, YhpSurf - 12, SurfaceDesc)
          else
          begin
            AoWHSSet.FRaceResources.GetRaceResource(FFlagID).FImageLibrary[FArmy.Count + 29].Show(XhpSurf - 5, YhpSurf - 12, SurfaceDesc);
            if asShowCrown in FArmy.FStatus then AoWHSSet.FFlagControl.FFlags[FFlagID + 80].Show(XhpSurf - 5, YhpSurf - 14, SurfaceDesc);
          end;
      end;
    end
    else if not (asFullyConcealed in FArmy.FStatus) then
    begin
      while Sequence <> nil do
      begin
        Frame := Sequence.GetFrameIndex(AoWHSMap.Frame, (Integer(Self) shr 2) and $FFFF);
        if Frame <> -1 then Sequence.ImageLibrary[Frame].Show(XhpSurf + Sequence.dXshift,
          YhpSurf + Sequence.dYshift + FUnitYOffset, SurfaceDesc);
        Sequence := Sequence.Next;
      end;
      if not (asSelected in FArmy.FStatus) or (AoWHSMap.Frame and 6 <> 6) then
        if FFlagID = $20 then AoWHSSet.FFlagControl.FFlags[FArmy.Count - FArmy.ConcealedUnitsCount + 39].Show(XhpSurf - 5, YhpSurf - 12, SurfaceDesc)
        else
        begin
          AoWHSSet.FRaceResources.GetRaceResource(FFlagID).FImageLibrary[FArmy.Count - FArmy.ConcealedUnitsCount + 29].Show(XhpSurf - 5, YhpSurf - 12, SurfaceDesc);
          if asShowCrown in FArmy.FStatus then AoWHSSet.FFlagControl.FFlags[FFlagID + 80].Show(XhpSurf - 5, YhpSurf - 14, SurfaceDesc);
        end;
    end;
  end;
end;

procedure TArmyHS.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if (Msg.MsgID and $40000000 = 0) and (FArmy <> nil) then FArmy.MsgProc(Msg, Sender);
  if Msg.MsgID = $20020005 then UpdateFlagID;
end;

procedure TArmyHS.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin
  inherited MapFieldMsgProc(Msg);
  if Msg.HN = 0 then
    if Msg.MsgID = $110C then
    begin
      if not (asFullyConcealed in FArmy.FStatus) and ((AoWHSMap.FFogEnabled = 0) or
        (WordRec(LongRec(TAoWMapField(Owner).FFieldFlags).Hi).Lo <> 0)) then
        if FArmy.FPlayer = 0 then Msg.Param[0] := Msg.Param[0] or $D
        else Msg.Param[0] := Msg.Param[0] or (AoWHSMap.FPlayers.GetPlayers(FArmy.FPlayer).FPlayerRace + 1);
    end
    else if Msg.MsgID = $1200 then
    begin
      FArmy.UpdateAITarget(TAITargetInfo(Pointer(Msg.Param[0])^), TAITargetData(Pointer(Msg.Param[1])^));
      if TAITargetData(Pointer(Msg.Param[1])^).Priority < 0 then Msg.Result := 1;
    end
    else if Msg.MsgID = $1108 then FArmy.ReturnBattleFieldInfo(TBattleFieldInfo(Pointer(Msg.Param[0])^))
    else if Msg.MsgID = $1101 then Msg.Param[1] := Ord(FArmy.GetMoveAction(Msg.Param[0]))
    else if Msg.MsgID = $1100 then Msg.Result := FArmy.FPlayer
    else if Msg.MsgID = $1125 then
    begin
      if FArmy.FPlayer = 0 then Msg.Result := FArmy.FIndependentRelation;
    end
    else if Msg.MsgID = $1130 then
    begin
      if Msg.Param[1] = 1 then Msg.Result := FArmy.FPlayer
      else if FArmy.FConcealedUnits <> ArmySelectionMasks[FArmy.FChildren.Count] then Msg.Result := FArmy.FPlayer;
    end
    else if Msg.MsgID = $110A then
    begin
      if (FArmy.FPlayer = Msg.Param[1]) or
        (AoWHSMap.FPlayers.GetPlayers(FArmy.FPlayer).FDiplomaticRelations.GetDiplomaticRelation(Msg.Param[1]) = drAlliance) then
        if Msg.Param[0] <= FArmy.VisibilityRange then Msg.Result := 1;
    end
    else if Msg.MsgID = $110B then
    begin
      if (FArmy.FPlayer = Msg.Param[1]) or
        (AoWHSMap.FPlayers.GetPlayers(FArmy.FPlayer).FDiplomaticRelations.GetDiplomaticRelation(Msg.Param[1]) = drAlliance) then
        if Msg.Param[0] <= FArmy.TrueVisionRange then Msg.Result := 1;
    end
    else if Msg.MsgID = $110D then
    begin
      if Msg.Param[0] < 9 then FArmy.UpdateConcealment;
      if (FArmy.FPlayer > 0) and (Msg.Param[0] <= FArmy.VisibilityRange) then
        AoWHSMap.UpdatePlayerSeen(FArmy.FPlayer, Msg.MapField.Xhx, Msg.MapField.Yhx, Msg.MapField.Lhx,
          Msg.Param[0], FArmy.TrueVisionRange);
    end
    else if Msg.MsgID = $110E then
    begin
      if FArmy.IncommingNegotiateRequest(TNegotiateRequestEventLog(Msg.Param[0])) then Msg.Param[1] := 1;
    end
    else if Msg.MsgID = $110F then
    begin
      if FArmy.IncommingNegotiateOffer(TNegotiateTE(Msg.Param[0])) then Msg.Result := 1;
    end
    else if (Msg.MsgID = $1150) and not TAoWMapField(Msg.MapField).GetMagicShieldActive then
    begin
      FArmy.IncommingStorm(TStormType(Msg.Param[0]), Msg.Param[1], Msg.Param[2]);
      Exit;
    end
    else if (Msg.MsgID = $1151) and not TAoWMapField(Msg.MapField).GetMagicShieldActive then
    begin
      FArmy.RetrieveStormDamageInfo(TStormType(Msg.Param[0]), Msg.Param[1], TStormDamageInfo(Pointer(Msg.Param[2])^));
      Exit;
    end
    else if Msg.MsgID = $1105 then FArmy.TriggerFireDamage;
end;

function TArmyHS.PlaceEx(X, Y, L: Shortint; Mode: TArmyPlaceMode): Boolean;
var Level: TMapLevel; Field: TAoWMapField; Walk: THNWalkData; Msg: TMapFieldMsg;
begin
  Result := False;
  Level := AoWHSMap.MapContainer.GetMapLevel(L);
  InitHNWalk(Walk, X, Y, 0);
  while not Result and ((Walk.Radius = 0) or (apScanArea in Mode)) and (Walk.Radius < 30) do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
    begin
      Field := TAoWMapField(Level.GetField(Walk.X, Walk.Y));
      if Field.FindOwnedChild($20217) = nil then
        if (Field.GetPlayer = -1) or ((Field.GetPlayer = FArmy.FPlayer) and (apEnableOwnPlayerLocation in Mode)) then
        begin
          Msg.MsgID := $1120;
          Msg.Param[0] := Integer(Self);
          Msg.Result := 0;
          Field.SendMapFieldMsg(Msg);
          if Msg.Result = 0 then
            if FArmy.CanPlace(Walk.X, Walk.Y, L) then
            begin MoveTo(Field, 0); Result := True; end;
        end;
    end;
    WalkToNextHN(Walk);
  end;
end;

function TArmyHS.MoveFirst(Direction: Byte; Instant: Boolean): Shortint;
var Level: TMapLevel; X, Y, DX, DY: Integer; Animation: TImageSequenceAnimation;
begin
  Result := inherited MoveFirst(Direction, Instant);
  case AoWEngine.FRegistry.GetMovementSpeed of
    mmsNormal: FMoveSteps := inherited GetMoveSteps;
    mmsFast:
      begin
        FMoveSteps := inherited GetMoveSteps;
        if FMoveSteps < 9 then FMoveSteps := 4 else Dec(FMoveSteps, 4);
      end;
    mmsTurbo: FMoveSteps := 2;
  end;
  if AoWHSMap.FFPS > 0 then
  begin
    if AoWHSMap.FFPS < 15 then FMoveSteps := FMoveSteps div 2
    else if AoWHSMap.FFPS < 25 then Dec(FMoveSteps, 2);
    if FMoveSteps < 2 then FMoveSteps := 2;
  end;
  if GetLhx > 0 then
  begin
    Level := TMapLevel(Owner.Owner);
    CenterHNtoHX(GetXhx, GetYhx, Direction, X, Y);
    if (X >= 0) and (Y >= 0) and (X < Level.Width) and (Y < Level.Height) then
      if Level.GetField(X, Y).TerrainType = 7 then
        if AoWHSSet.FAbilityControl.GetAbility(42).FImageSequences.GetImageSequence(0) <> nil then
        begin
          Animation := TImageSequenceAnimation.Create(nil);
          Animation.SetImageSequence(AoWHSSet.FAbilityControl.GetAbility(42).FImageSequences.GetImageSequence(0));
          Animation.FAnimationLevel := 27;
          HNtoHP(Direction, DX, DY);
          Animation.SetXhpOffset(DX div 2);
          Animation.SetYhpOffset(DY div 2);
          AoWHSMap.PlaceHX(Animation, GetXhx, GetYhx, GetLhx);
        end;
  end;
end;

function TArmyHS.GetMoveSteps: Integer;
begin
  if Moving then
  begin Result := FMoveSteps; Exit; end;
  Result := inherited GetMoveSteps;
end;

function TArmyHSList.GetArmyHS(Index: Integer): TArmyHS;
begin
  Result := TArmyHS(FChildren.List^[Index]);
end;

resourcestring
  SelectRoadConstructionPathRStr = 'Select road construction path';
  ArmyNotEnoughMovePointsRStr = 'Not enough move points';
  ArmyRoadConstructionCostRStr = 'Constructing road will cost %s gold';
  ArmyNotAtWarRStr = 'Not at war with the %s';

constructor TSelectedArmy.Create;
begin
  inherited Create;
  FSelectedUnitGFX := TIntegerList.Create;
end;

destructor TSelectedArmy.Destroy;
begin
  ResetSelectedUnitGFX;
  FSelectedUnitGFX.Free;
  inherited Destroy;
end;

procedure TSelectedArmy.SetCurrentMove(A1: Integer);
begin
  if (FCurrentMove <> -1) and (GetArmyHS <> nil) then
    AoWHSMap.Selection.Unselect(GetArmyHS);
  FCurrentMove := A1;
  if (FCurrentMove <> -1) and (GetArmyHS <> nil) then
    AoWHSMap.Selection.Select(GetArmyHS);
  UpdateSelectedUnitGFX;
end;

function TSelectedArmy.AddMoveArmy(ArmyHS: TArmyHS; Selection: Byte): Integer;
var Index: Integer;
begin
  Index := AddMoveObject(ArmyHS);
  FMoveSettingsList.GetMoveSettings(Index).FSelection := Selection;
  FMoveSettingsList.GetMoveSettings(Index).FMovePoints := ArmyHS.FArmy.MovePoints(Selection);
  FMoveSettingsList.GetMoveSettings(Index).FMoves := ArmyHS.FArmy.Moves(Selection);
  Result := Index;
end;

function TSelectedArmy.GetArmyHS: TArmyHS;
begin
  if FCurrentMove <> -1 then
    Result := TArmyHS(FMoveSettingsList.GetMoveSettings(FCurrentMove).FMoveObject)
  else Result := nil;
end;

function TSelectedArmy.GetSelection: Byte;
begin
  if FCurrentMove <> -1 then
    Result := FMoveSettingsList.GetMoveSettings(FCurrentMove).FSelection
  else Result := 0;
end;

procedure TSelectedArmy.SetSelection(Selection: Byte);
var Points, Moves: Integer;
begin
  if FCurrentMove <> -1 then
  begin
    Selection := GetArmyHS.FArmy.ValidateMoveSelection(Selection);
    if FMode = samBuildRoads then
      Selection := Selection or (1 shl GetArmyHS.FArmy.IndexOfID(FRoadBuilderID));
    if Selection <> 0 then
    begin
      FMoveSettingsList.GetMoveSettings(FCurrentMove).FSelection := Selection;
      Points := GetArmyHS.FArmy.MovePoints(Selection);
      FMoveSettingsList.GetMoveSettings(FCurrentMove).FMovePoints := Points;
      Moves := GetArmyHS.FArmy.Moves(Selection);
      FMoveSettingsList.GetMoveSettings(FCurrentMove).FMoves := Moves;
    end;
    Update;
  end;
end;

function TSelectedArmy.GetMoveTypes: TMoveTypes;
begin
  if FCurrentMove <> -1 then
    Result := TArmyHS(FMoveSettingsList.GetMoveSettings(FCurrentMove).FMoveObject).FArmy.MoveTypes(
      FMoveSettingsList.GetMoveSettings(FCurrentMove).FSelection)
  else Result := [];
end;

procedure TSelectedArmy.ShowMovePaths(const Surface: TSurfaceDesc);
begin
  if Self = AoWHSMap.Mouse.Capture then inherited ShowMovePaths(Surface);
end;

procedure TSelectedArmy.ResetSelectedUnitGFX;
var I: Integer;
begin
  for I := FSelectedUnitGFX.Count - 1 downto 0 do
  begin
    AoWHSSet.FUnitGFXResources.GetUnitGFXResource(FSelectedUnitGFX[I]).Release;
    FSelectedUnitGFX.Delete(I);
  end;
end;

procedure TSelectedArmy.UpdateSelectedUnitGFX;
var I, Index: Integer; List: TIntegerList;
begin
  List := TIntegerList.Create;
  if GetArmyHS <> nil then
    for I := 0 to GetArmyHS.FArmy.Count - 1 do
    begin
      Index := GetArmyHS.FArmy.GetUnit(I).GetUnitGFXResourceIndex;
      List.Add(Index);
      AoWHSSet.FUnitGFXResources.GetUnitGFXResource(Index).AddRef;
    end;
  ResetSelectedUnitGFX;
  FSelectedUnitGFX.Assign(List);
  List.Free;
end;

procedure TSelectedArmy.OnDestroyArmy(Sender: TObject);
var Index: Integer;
begin
  if mssActivated in FStatus then
    if TArmy(Sender) <> nil then
    begin
      Index := FMoveSettingsList.IndexOfMoveObject(TArmy(Sender).GetArmyHS);
      if Index <> -1 then DeleteMoveObject(Index);
    end
    else Deactivate;
end;

procedure TSelectedArmy.RectangleSelectEvent(Sender: TObject);
var
  X1, Y1, X2, Y2, Xhp, Yhp: Integer;
  X, Y: Integer;
  Armies: TArmyHSList;
  I: Integer;
  R: TRect;
  Level: TMapLevel;
  ArmyHS: TArmyHS;
begin
  Armies := TArmyHSList.Create(nil);
  R := TAbstractAoWHSMapMouse(Sender).FSelectionRectangle;
  Level := AoWHSMap.MapContainer.GetMapLevel(AoWHSMap.ViewL);
  HPtoHX(R.Left, R.Top, X1, Y1);
  HPtoHX(R.Right, R.Bottom, X2, Y2);
  for X := X1 - 1 to X2 + 1 do
    for Y := Y1 - 1 to Y2 + 1 do
    begin
      HXtoHP(X, Y, Xhp, Yhp);
      Inc(Xhp, 16);
      Inc(Yhp, 16);
      if (X >= 0) and (X < Level.Width) and (Y > 0) and (Y < Level.Height) and
        (Xhp >= R.Left) and (Xhp < R.Right) and
        (Yhp >= R.Top) and (Yhp < R.Bottom) then
      begin
        ArmyHS := TAoWMapField(Level.GetField(X, Y)).GetArmyHS;
        if (ArmyHS <> nil) and (ArmyHS.FArmy.FPlayer = AoWHSMap.FSeatedPlayer) then
          Armies.AddChild(ArmyHS);
      end;
    end;
  if Armies.Count <> 0 then
  begin
    Clear;
    AoWHSMap.Selection.UnselectLocation;
    for I := 0 to Armies.Count - 1 do
    begin
      AddMoveArmy(Armies.GetArmyHS(I), $FF);
      AoWHSMap.Selection.SelectLocationHS(Armies.GetArmyHS(I));
    end;
    if Armies.Count = 1 then SetCurrentMove(0)
    else SetCurrentMove(-1);
    Update;
  end;
  Armies.Free;
end;

function TSelectedArmy.ValidMultiMoveSelection(Field: TAoWMapField): Boolean;
var Player: Shortint; Valid: Boolean; ArmyHS: TArmyHS;
begin
  Player := Field.GetPlayer;
  Valid := (Player = -1) or (Player = AoWHSMap.FSeatedPlayer);
  ArmyHS := Field.GetArmyHS;
  if ArmyHS <> nil then Valid := Valid and (ArmyHS.FArmy.Transporter($FF) = nil);
  Valid := Valid and (FMode <> samBuildRoads);
  Result := Valid;
end;

function TSelectedArmy.ValidateSelection(Field: TAoWMapField): Boolean;
begin
  if FMoveSettingsList.Count > 1 then Result := ValidMultiMoveSelection(Field)
  else Result := inherited ValidateSelection(Field);
  if FMode = samBuildRoads then
    if (Field.GetPlayer <> -1) and
      (Field.GetPlayer <> GetArmyHS.FArmy.FPlayer) then Result := False;
end;

procedure TSelectedArmy.CalculateMovePath(Index: Integer; X, Y, L: Shortint);
var
  Settings: TMoveSettings;
  ArmyHS: TArmyHS;
begin
  if X <> -1 then
  begin
    Settings := FMoveSettingsList.GetMoveSettings(Index);
    ArmyHS := TArmyHS(Settings.FMoveObject);
    Settings.FPathMovePoints := 0;
    FMoveControlSettings.Reset;
    FMoveControlSettings.SetSourcePos(ArmyHS.GetXhx, ArmyHS.GetYhx, ArmyHS.GetLhx);
    FMoveControlSettings.FPlayer := ArmyHS.FArmy.FPlayer;
    FMoveControlSettings.FArmyHS := ArmyHS;
    FMoveControlSettings.SetDestinationPos(X, Y, L);
    FMoveControlSettings.FUnits.AddUnitsEx(ArmyHS.FArmy, Settings.FSelection);
    if AoWHSMap.FExplorationEnabled then
      FMoveControlSettings.FMode := FMoveControlSettings.FMode + [mmExploredTerrainOnly];
    ArmyHS.FArmy.CreateMovePointTable(Settings.FSelection, FMoveControlSettings.FMovePointTable);
    AoWHSMap.FMoveControl.ProcessMove(FMoveControlSettings);
    if FMoveControlSettings.FPath.Count <> 0 then
    begin
      Settings.FPath.Assign(FMoveControlSettings.FPath);
      Settings.FPathMovePoints := Settings.FPath.PosToMovePoints(0);
      ArmyHS.FArmy.SetDestinationPos(Settings.FPath[0].X, Settings.FPath[0].Y, Settings.FPath[0].L);
      FMoveControlSettings.FPath.Clear;
      if FMode = samBuildRoads then
        if Settings.FMovePoints < Settings.FPathMovePoints then
        begin
          Settings.FPath.Clear;
          AoWHSMap.ShowMessage(TranslateRStr(ArmyNotEnoughMovePointsRStr));
        end
        else if Settings.FPath.Count <> 0 then
          AoWHSMap.ShowMessage(Format(TranslateRStr(ArmyRoadConstructionCostRStr),
            [IntToStr(RoadConstructionCost(GetArmyHS.FArmy.FPlayer, Settings.FPath, Settings.FMovePoints))]));
    end
    else
    begin
      FMoveSettingsList.GetMoveSettings(Index).FPath.Clear;
      ArmyHS.FArmy.ResetDestinationPos;
    end;
  end;
end;

procedure TSelectedArmy.SelectPath(X, Y, L: Shortint);
var
  Valid: Boolean;
  I: Integer;
  Settings: TMoveSettings;
begin
  if (GetArmyHS <> nil) and (GetArmyHS.GetXhx = AoWHSMap.Mouse.Xhx) and
    (GetArmyHS.GetYhx = AoWHSMap.Mouse.Yhx) and
    (GetArmyHS.GetLhx = AoWHSMap.ViewL) then
    AoWHSMap.Selection.SelectLocationHX(GetArmyHS.GetXhx, GetArmyHS.GetYhx, GetArmyHS.GetLhx)
  else if (FMoveSettingsList.Count > 1) and (FCurrentMove = -1) then
  begin
    Valid := True;
    I := FMoveSettingsList.Count;
    while Valid and (I <> 0) do
    begin
      Dec(I);
      Settings := FMoveSettingsList.GetMoveSettings(I);
      with Settings do
        Valid := (FPath.Count <> 0) and (FPath[0].X = X) and
          (FPath[0].Y = Y) and (FPath[0].L = L);
    end;
    if not Valid then
    begin
      if ValidateSelection(TAoWMapField(FMap.MapContainer.GetField(X, Y, L))) then
        for I := 0 to FMoveSettingsList.Count - 1 do
          CalculateMovePath(I, X, Y, L)
      else
        for I := 0 to FMoveSettingsList.Count - 1 do
          FMoveSettingsList.GetMoveSettings(I).FPath.Clear;
    end
    else ExecuteMove;
  end
  else inherited SelectPath(X, Y, L);
end;

procedure TSelectedArmy.Unselect;
begin
  inherited Unselect;
  Select(nil);
end;

procedure TSelectedArmy.MouseDownEvent(Sender: TObject);
var
  ArmyHS: TArmyHS;
  Index: Integer;
begin
  if not FIgnoreMouseDown then
    if ssShift in AoWHSMap.Mouse.Shift then
    begin
      if (FMoveSettingsList.Count = 1) and
        (FMoveSettingsList.GetMoveSettings(0).FPath.Count <> 0) then
        if not ValidMultiMoveSelection(TAoWMapField(FMap.MapContainer.GetField(
          FMoveSettingsList.GetMoveSettings(0).FPath[0].X,
          FMoveSettingsList.GetMoveSettings(0).FPath[0].Y,
          FMoveSettingsList.GetMoveSettings(0).FPath[0].L))) then Exit;
      if AoWHSMap.Mouse.Xhx <> -1 then
      begin
        ArmyHS := TArmyHS(AoWHSMap.MapContainer.GetField(AoWHSMap.Mouse.Xhx,
          AoWHSMap.Mouse.Yhx, AoWHSMap.ViewL).FindOwnedChild($20217));
        if (ArmyHS <> nil) and (ArmyHS.FArmy.FPlayer = AoWHSMap.FSeatedPlayer) then
        begin
          Index := FMoveSettingsList.IndexOfMoveObject(ArmyHS);
          if Index = -1 then
          begin
            AddMoveArmy(ArmyHS, $FF);
            Update;
            AoWHSMap.Selection.SelectLocationHS(ArmyHS);
            SetCurrentMove(-1);
          end
          else
          begin
            ArmyHS.Unselect;
            DeleteMoveObject(Index);
            if FMoveSettingsList.Count = 1 then SetCurrentMove(0);
          end;
        end;
      end;
    end
    else if ssCtrl in AoWHSMap.Mouse.Shift then
    begin
      if (FMoveSettingsList.Count > 1) and (AoWHSMap.Mouse.Xhx <> -1) then
      begin
        ArmyHS := TArmyHS(AoWHSMap.MapContainer.GetField(AoWHSMap.Mouse.Xhx,
          AoWHSMap.Mouse.Yhx, AoWHSMap.ViewL).FindOwnedChild($20217));
        if (ArmyHS <> nil) and (ArmyHS.FArmy.FPlayer = AoWHSMap.FSeatedPlayer) then
        begin
          Index := FMoveSettingsList.IndexOfMoveObject(ArmyHS);
          if Index <> -1 then
            if Index <> FCurrentMove then
            begin
              SetCurrentMove(Index);
              Update;
            end
            else SetCurrentMove(-1);
        end;
      end;
    end
    else
    begin
      if (AoWHSMap.Mouse.Capture <> AoWHSMap.FTargetSelection) and
        ((AoWHSMap.Mouse.Capture <> Self) or (FMap.Mouse.Button = mbRight)) then
        Unselect
      else if (AoWHSMap.Mouse.Capture = Self) and (AoWHSMap.Mouse.Button = mbLeft) then
        SelectPath(FMap.Mouse.Xhx, FMap.Mouse.Yhx, FMap.ViewL);
    end
  else FIgnoreMouseDown := False;
end;

procedure TSelectedArmy.ExecuteMove;
var
  I: Integer;
  ArmyHS: TArmyHS;
  Field: TAoWMapField;
  Cost: Integer;
begin
  if FMoveSettingsList.Count = 1 then
  begin
    with FMoveSettingsList.GetMoveSettings(FCurrentMove) do
    if (FPath.Count > 1) and (GetArmyHS <> nil) then
    begin
      ArmyHS := GetArmyHS;
      Field := TAoWMapField(AoWHSMap.MapContainer.GetField(FPath[0].X,
        FPath[0].Y, FPath[0].L));
      if (Field.GetMoveAction(ArmyHS.FArmy.FPlayer) <> maAttack) or (Field.GetPlayer <= 0) or
        (AoWHSMap.FPlayers.GetDiplomaticRelation(ArmyHS.FArmy.FPlayer, Field.GetPlayer) in [drWar, drUnknown]) then
      begin
        if FMode = samBuildRoads then
        begin
          Cost := RoadConstructionCost(ArmyHS.FArmy.FPlayer, FPath, FMovePoints);
          if Cost <= AoWHSMap.FPlayers.GetPlayers(ArmyHS.FArmy.FPlayer).FGems then
          begin
            if MoveArmyEx(ArmyHS, GetSelection, FPath, [mmSelectEndLocation, mmBuildRoads], False) then
            begin
              FPath.Clear;
              if msEditting in AoWHSMap.Status then AoWHSMap.Selection.UnselectLocation;
              DeactivateMoveSelection;
            end;
          end
          else AoWHSMap.ShowWarning(TranslateRStr(NotEnoughGoldRStr));
        end
        else
        begin
          ArmyHS.FArmy.SetDestinationPos(FPath[0].X, FPath[0].Y, FPath[0].L);
          if MoveArmy(ArmyHS, GetSelection, FPath) then
          begin
            if FPath.MovePointsToPos(ArmyHS.FArmy.MovePoints($FF)) > 0 then
              with ArmyHS.FArmy do Include(FUserMode, aumTurnDone);
            FPath.Clear;
            if msEditting in AoWHSMap.Status then AoWHSMap.Selection.UnselectLocation;
            DeactivateMoveSelection;
          end;
        end;
      end
      else if (PByteArray(Field)^[26] <> 0) or (AoWHSMap.FFogEnabled = 0) then
        AoWHSMap.ShowMessage(Format(TranslateRStr(ArmyNotAtWarRStr),
          [TranslateRStr(RaceNamesPluralRStr[AoWHSMap.FPlayers.GetPlayers(Field.GetPlayer).FPlayerRace])]));
    end;
  end
  else if (FMoveSettingsList.Count > 1) and ExecuteMultiArmyMove(FMoveSettingsList) then
  begin
    for I := 0 to FMoveSettingsList.Count - 1 do
    begin
      with FMoveSettingsList.GetMoveSettings(I) do
      begin
        TArmyHS(FMoveObject).FArmy.SetDestinationPos(FPath[0].X, FPath[0].Y, FPath[0].L);
        FPath.Clear;
      end;
    end;
    Deactivate;
    AoWHSMap.Selection.UnselectLocation;
    Clear;
  end;
end;

procedure TSelectedArmy.UpdateMoveCursor;
var Field: TAoWMapField; Cost: Integer;
begin
  if (AoWHSMap.Mouse.Xhx <> -1) and (AoWHSMap.Mouse.Yhx <> -1) and
    (AoWHSMap.Mouse.Capture = Self) then
  begin
    Field := TAoWMapField(AoWHSMap.MapContainer.GetField(AoWHSMap.Mouse.Xhx,
      AoWHSMap.Mouse.Yhx, AoWHSMap.ViewL));
    if (FCurrentMove <> -1) and
      (not AoWHSMap.FExplorationEnabled or Field.GetExplored(AoWHSMap.FSeatedPlayer)) and
      ((AoWHSMap.FFogEnabled = 0) or (PByteArray(Field)^[26] <> 0)) then
      case Field.GetMoveAction(GetArmyHS.FArmy.FPlayer) of
        maAttack: AoWHSMap.Mouse.CursorMode := $102;
        maNegotiate: AoWHSMap.Mouse.CursorMode := $103;
      else
        AoWHSMap.Mouse.CursorMode := $100;
      end
    else if FMoveSettingsList.Count <= 1 then AoWHSMap.Mouse.CursorMode := $100
    else AoWHSMap.Mouse.CursorMode := 0;
    if AoWHSMap.Mouse.CursorMode = $100 then
    begin
      if mtWalking in GetMoveTypes then AoWHSMap.Mouse.Cursor := $40
      else if mtSwimming in GetMoveTypes then AoWHSMap.Mouse.Cursor := $42
      else if mtFlying in GetMoveTypes then AoWHSMap.Mouse.Cursor := $44;
      Cost := FMoveControlSettings.FMovePointTable[Field.TerrainType, Field.OverlayType + 1];
      if (Cost = 0) or (AoWHSMap.FExplorationEnabled and
        not Field.GetExplored(AoWHSMap.FSeatedPlayer)) then
        with AoWHSMap.Mouse do Cursor := Cursor or 1;
    end;
  end;
end;

procedure TSelectedArmy.ActivateMoveSelection;
begin
  Activate(AoWHSMap);
end;

procedure TSelectedArmy.Deactivate;
begin
  inherited Deactivate;
  FMode := samDefault;
end;

procedure TSelectedArmy.DeactivateMoveSelection;
begin
  Deactivate;
end;

procedure TSelectedArmy.Update;
var
  Selection: Byte;
  Field: TMapField;
  Pos: TXYL;
  I: Integer;
  ArmyHS: TArmyHS;
  Points: Integer;
begin
  UpdateSelectedUnitGFX;
  if GetArmyHS <> nil then
    GetArmyHS.FArmy.CreateMovePointTable(GetSelection, FMoveControlSettings.FMovePointTable);
  for I := 0 to FMoveSettingsList.Count - 1 do
  begin
    Selection := FMoveSettingsList.GetMoveSettings(I).FSelection;
    ArmyHS := TArmyHS(FMoveSettingsList.GetMoveSettings(I).FMoveObject);
    Points := ArmyHS.FArmy.MovePoints(Selection);
    FMoveSettingsList.GetMoveSettings(I).FMovePoints := Points;
    Points := ArmyHS.FArmy.Moves(Selection);
    FMoveSettingsList.GetMoveSettings(I).FMoves := Points;
  end;
  if mssActivated in FStatus then
    for I := 0 to FMoveSettingsList.Count - 1 do
    begin
      ArmyHS := TArmyHS(FMoveSettingsList.GetMoveSettings(I).FMoveObject);
      if ArmyHS.FArmy.FPlayer = AoWHSMap.FSeatedPlayer then
        if (ArmyHS.FArmy.FDestinationX <> -1) and (ArmyHS.FArmy.FDestinationX <> 0) then
        begin
          with ArmyHS.FArmy do
          begin
            Field := AoWHSMap.MapContainer.GetField(FDestinationX, FDestinationY, FDestinationL);
            if Self.ValidateSelection(TAoWMapField(Field)) then
              CalculateMovePath(I, FDestinationX, FDestinationY, FDestinationL)
            else ArmyHS.FArmy.ResetDestinationPos;
          end;
        end
        else if FMoveSettingsList.GetMoveSettings(I).FPath.Count <> 0 then
        begin
          Pos := FMoveSettingsList.GetMoveSettings(I).FPath[0];
          CalculateMovePath(I, Pos.X, Pos.Y, Pos.L);
        end;
    end;
  UpdateMoveCursor;
end;

procedure TSelectedArmy.OutputGroupInfo;
var
  Text: string;
  I: Integer;
  Group: TAIGroup;
begin
  Text := '';
  for I := 0 to GetArmyHS.FArmy.Count - 1 do
  begin
    Text := GetArmyHS.FArmy.GetUnit(I).GetName + '(ID:' +
      IntToStr(GetArmyHS.FArmy.GetUnit(I).FUnitID) + ')';
    Group := GetArmyHS.FArmy.GetUnit(I).FGroup;
    if Group <> nil then
    begin
      Text := Text + TGroupBehaviorStr[Group.Behavior] + '(GID:' + IntToStr(Group.FGroupID) +
        '/Target:' + IntToStr(Group.FTargetXYL.X) + ',' + IntToStr(Group.FTargetXYL.Y) +
        ',' + IntToStr(Group.FTargetXYL.L) + '/Budget:' + IntToStr(Group.FGoldBudget) +
        '/MP:' + IntToStr(Group.FTargetMovePoints) + ')';
      if Group.FTargetType = gtsSetup then Text := Text + '-setup'
      else if Group.FTargetType = gtsExecute then Text := Text + '-execute';
      if Group.FLeader = GetArmyHS.FArmy.GetUnit(I) then Text := Text + '/Leader';
    end;
    AoWEngine.OutputDebugStr(Text);
  end;
  AoWEngine.OutputDebugStr('Army strength: ' + IntToStr(GetArmyHS.FArmy.GetStrengthMax(dtAll - [dtNone])));
end;

procedure TSelectedArmy.SetArmyHS(ArmyHS: TArmyHS);
begin
  if (ArmyHS <> GetArmyHS) and not (msEditting in AoWHSMap.Status) and
    (FMoveSettingsList.Count <= 1) then
  begin
    Clear;
    FIgnoreMouseDown := False;
    FMode := samDefault;
    if ArmyHS <> nil then
    begin
      if ArmyHS.FArmy.FPlayer = AoWHSMap.FSeatedPlayer then ActivateMoveSelection;
      AddMoveArmy(ArmyHS, $FF);
      FCurrentMove := 0;
      Update;
    end
    else
    begin
      DeactivateMoveSelection;
      ResetSelectedUnitGFX;
    end;
    if (GetArmyHS <> nil) and AoWEngine.FRegistry.GetDebugMode then OutputGroupInfo;
  end;
end;

procedure TSelectedArmy.Select(ArmyHS: TArmyHS);
begin
  AoWHSMap.Selection.UnselectLocation;
  if ArmyHS <> nil then AoWHSMap.Selection.SelectLocationHS(ArmyHS);
end;

procedure TSelectedArmy.SelectBuildRoad(AUnit: TAbstractUnit);
var Army: TECustomNode; ArmyHS: TArmyHS;
begin
  Army := AUnit.Owner;
  if Army is TArmy then
  begin
    ArmyHS := TArmy(Army).GetArmyHS;
    ArmyHS.FArmy.ResetDestinationPos;
    if ArmyHS <> GetArmyHS then
    begin
      AoWHSMap.Selection.UnselectLocation;
      AoWHSMap.Selection.SelectLocationHS(ArmyHS);
      SetSelection($FF);
    end
    else
    begin
      DeleteMoves;
      AddMoveArmy(ArmyHS, $FF);
      FCurrentMove := 0;
    end;
    AoWHSMap.ShowMessage(TranslateRStr(SelectRoadConstructionPathRStr));
    FRoadBuilderID := AUnit.FUnitID;
    FMode := samBuildRoads;
  end;
end;

procedure TSelectedArmy.Center;
begin
  if GetArmyHS <> nil then
    with AoWHSMap do
      CenterViewTo(GetArmyHS.GetXhx, GetArmyHS.GetYhx, GetArmyHS.GetLhx);
end;

procedure TSelectedArmy.TurnDone;
begin
  if (GetArmyHS <> nil) and (GetArmyHS.FArmy.FPlayer = AoWHSMap.FSeatedPlayer) then
  begin
    Include(GetArmyHS.FArmy.FUserMode, aumTurnDone);
    AoWHSMap.SelectNextArmy;
  end;
end;

procedure TSelectedArmy.ToggleGuard;
var ArmyHS: TArmyHS; Army: TArmy;
begin
  ArmyHS := GetArmyHS;
  if (ArmyHS <> nil) and (ArmyHS.FArmy.FPlayer = AoWHSMap.FSeatedPlayer) then
  begin
    Army := ArmyHS.FArmy;
    if aumGuard in TArmyUserMode(Army.FMode) then
    begin
      Exclude(TArmyUserMode(Army.FMode), aumGuard);
      Army.Update;
    end
    else
    begin
      Include(TArmyUserMode(Army.FMode), aumGuard);
      AoWHSMap.SelectNextArmy;
    end;
  end;
end;

resourcestring
  ItemSpellResearchedRStr = '%s researched';
  ItemSpellAlreadyResearchedRStr = '%s already researched';
  ItemNotUseableRStr = 'This is not an usable item';
  ItemSystemLibraryRStr = 'System';

class function TItemTE.ClassID: Integer;
begin Result := $20272; end;

procedure TItemTE.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FItemID, $14);
  Stream.rwData(FAction, 1, $15);
  Stream.rwInteger(FHeroID, $16);
end;

function TItemTE.Execute(TE: TTokenExecuter): TExecuteResult;
var Done: Boolean; Item: TItem; Hero: THero;
begin
  inherited Execute(TE);
  Done := False;
  Item := AoWHSMap.FItemControl.FindItem(FItemID);
  if Item <> nil then
    case FAction of
      0:
      begin
        Hero := AoWHSMap.FHeroControl.FindID(FHeroID);
        if Hero <> nil then Done := Item.ExecuteUse(Hero)
        else Done := False;
      end;
    end;
  if Done then Result := erDone else Result := erDoneHalt;
end;

constructor TItem.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FItemGFXIndex := -1;
  FDescription := TStringList.Create;
  FLibraryID := -1;
  FRefCount := 1;
end;

destructor TItem.Destroy;
begin
  AddRef;
  if isActivated in FStatus then Deactivate;
  if isRegistered in FStatus then AoWHSMap.FItemControl.UnRegisterItem(Self);
  FDescription.Free;
  inherited Destroy;
end;

function TItem.AddRef: Integer;
begin Inc(FRefCount); Result := FRefCount; end;

function TItem.Release: Integer;
var Count: Integer;
begin
  Dec(FRefCount);
  Count := FRefCount;
  Result := Count;
  if Count = 0 then Destroy;
end;

procedure TItem.SetOwner(AOwner: TECustomNode);
begin
  if AOwner <> FOwner then
  begin
    AddRef;
    if FOwner <> nil then FOwner.RemoveChild(Self);
    FOwner := AOwner;
    if FOwner <> nil then
      if FOwner.AddChild(Self) = -1 then FOwner := nil;
    Changed;
    Release;
  end;
end;

function TItem.ExecuteUse(Hero: THero): Boolean;
var Reason: string;
begin
  Result := True; { Original reports success even when CanUse rejects the item. }
  if CanUse(Hero, Reason) then
    case FItemType of
      itScroll:
      begin
        AoWHSMap.FPlayers.GetPlayers(Hero.FPlayer).FMagicControl.ExecuteSpellResearched(FSpellID);
        if AoWHSMap.FSeatedPlayer = Hero.FPlayer then
        begin
          PlaySample('SFX\ATTACK\MAGICB01.WAV');
          AoWHSMap.ShowMessage(Format(TranslateRStr(ItemSpellResearchedRStr),
            [AoWHSSet.FSpellControl.GetSpell(FSpellID).FSpellName]));
        end;
        Destroy;
        Hero.Changed;
      end;
    end;
end;

function TItem.CanUse(Hero: THero; var Reason: string): Boolean;
begin
  if (FItemType = itScroll) and (FSpellID <> 0) then
  begin
    if AoWHSMap.FPlayers.GetPlayers(Hero.FPlayer).FMagicControl.FSpells.IndexOf(FSpellID) = -1 then
      Result := True
    else
    begin
      Result := False;
      Reason := Format(TranslateRStr(ItemSpellAlreadyResearchedRStr),
        [AoWHSSet.FSpellControl.GetSpell(FSpellID).FSpellName]);
    end;
  end
  else
  begin
    Result := False;
    Reason := TranslateRStr(ItemNotUseableRStr);
  end;
end;

function TItem.Use(Hero: THero): Boolean;
var Reason: string; Event: TItemTE;
begin
  if CanUse(Hero, Reason) and not AoWHSMap.FPlayers.GetPlayers(Hero.FPlayer).GetBusy then
  begin
    Event := TItemTE.Create(nil);
    Event.FItemID := FItemID;
    Event.FHeroID := Hero.FUnitID;
    AoWHSMap.FTokenManager.GetTokenControl(Hero.FPlayer).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;

procedure TItem.SetArrayOwner(AOwner: TECustomNode; Index: Integer);
begin
  AddRef;
  inherited SetArrayOwner(AOwner, Index);
  if FOwner <> nil then AddRef;
  Changed;
  Release;
end;

procedure TItem.GetLocation(var X, Y, L: Shortint);
begin
  if (FOwner <> nil) and (FOwner is TItemList) then TItemList(FOwner).GetLocation(X, Y, L)
  else
  begin
    X := -1;
    Y := -1;
    L := -1;
  end;
end;

procedure TItem.Activate;
begin
  if not (isActivated in FStatus) then
  begin
    if (msEditting in AoWHSMap.Status) or (AoWHSMap.FDay = 0) then UpdateFromLibrary;
    FStatus := FStatus + [isActivated];
  end;
end;

procedure TItem.Deactivate;
begin
  if isActivated in FStatus then FStatus := FStatus - [isActivated];
end;

procedure TItem.Changed;
begin
  if isRegistered in FStatus then AoWHSMap.FItemControl.ItemChanged(Self);
end;

class function TItem.ClassID: Integer;
begin Result := $20268; end;

function TItem.GetCampaignTransferPoints: Integer;
begin Result := GetObtainValue; end;

function TItem.GetImage: TLibraryImage;
var GFX: TItemGFX;
begin
  GFX := AoWHSSet.FItemGFXResources.GetItemGFX(FItemGFXIndex);
  if GFX <> nil then
  begin
    GFX.AddRef;
    Result := GFX.GetItemImage;
    GFX.Release;
  end
  else Result := nil;
end;

function TItem.GetLibraryItem: Boolean;
begin Result := FLibraryID <> -1; end;

function TItem.GetLibraryName: string;
begin
  if FLibraryID <> -1 then
  begin
    Result := FLibraryName;
    if Result = '' then Result := TranslateRStr(ItemSystemLibraryRStr);
  end;
end;

procedure TItem.UpdateFromLibrary;
var ID: Integer; Item: TItem;
begin
  if FLibraryID <> -1 then
  begin
    Item := AoWHSSet.FItemLibraries.FindItem(FLibraryName, FLibraryID);
    if Item <> nil then
    begin
      ID := FItemID;
      Assign(Item, AoWEngine);
      FItemID := ID;
      Changed;
    end
    else if FOwner = nil then Free
    else FLibraryID := -1;
  end;
end;

function TItem.GetOwnerName: string;
begin Result := FOwnerName; end;

function TItem.GetAbilitySelectionTypes: TAbilitySelectionTypes;
begin
  case FItemType of
    itHead: Result := [astHeadItem];
    itTorso: Result := [astTorsoItem];
    itAttack: Result := [astAttackItem];
    itDefense: Result := [astDefenseItem];
    itRing: Result := [astRingItem];
    itUse: Result := [astUseItem];
  else Result := [];
  end;
end;

procedure TItem.SetItemGFXIndex(A1: Integer);
begin FItemGFXIndex := A1; end;

procedure TItem.Show(X, Y: Integer; const Surface: TSurfaceDesc);
var GFX: TItemGFX;
begin
  GFX := AoWHSSet.FItemGFXResources.GetItemGFX(FItemGFXIndex);
  if GFX <> nil then
  begin
    GFX.AddRef;
    GFX.GetItemImage.Show(X, Y, Surface);
    GFX.Release;
  end;
end;

procedure TItem.SetItemType(Value: TItemType);
var ItemType: TItemType;
begin
  FAttack := 0;
  FDefense := 0;
  FResistance := 0;
  FDamage := 0;
  ItemType := Value;
  FItemType := ItemType;
  FItemGFXIndex := AoWHSSet.FItemGFXResources.FindItemTypeGFX(ItemType);
  inherited Clear;
end;

function TItem.GetObtainValue: Integer;
begin
  if FObtainValue > 10 then Result := FObtainValue else Result := 10;
end;

procedure TItem.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  if not (smText in Stream.StorageMode) or not GetLibraryItem then
    Stream.rwInteger(FItemGFXIndex, 7);
  if not (smText in Stream.StorageMode) or (FOwner is TItemLibrary) or not GetLibraryItem then
    Stream.rwString(FOwnerName, 8);
  if not (smText in Stream.StorageMode) or not GetLibraryItem then
  begin
    Stream.rwString(FName, 9);
    Stream.rwData(FAvailability, 1, 10);
    Stream.rwByte(Byte(FAttack), 11);
    Stream.rwByte(Byte(FDefense), 12);
    Stream.rwByte(Byte(FDamage), 13);
    Stream.rwByte(Byte(FResistance), 14);
    Stream.rwData(FItemType, 1, 15);
    Stream.rwBool(FHidden, 16);
    Stream.rwInteger(FItemID, 17);
    Stream.rwStrings(FDescription, 18);
    Stream.rwInteger(FObtainValue, 19);
    Stream.rwInteger(FSpellID, 20);
    Stream.rwIntegerEx(FLibraryID, -1, 21);
    if not (smText in Stream.StorageMode) then Stream.rwString(FLibraryName, 22);
  end;
end;

function TItem.PlaceOnMap(Map: TAbstractAoWHSMap; X, Y, L: Shortint): Boolean;
var HS: TItemHS;
begin
  if (X >= 0) and (Y >= 0) and (L >= 0) and (X < Map.MapContainer.Width) and
    (Y < Map.MapContainer.Height) and (L < Map.MapContainer.LevelCount) and
    (Map.MapContainer.GetField(X, Y, L).TerrainType <> 15) then
  begin
    HS := TItemHS(Map.MapContainer.GetField(X, Y, L).FindOwnedChild($20271));
    if HS = nil then
    begin
      HS := TItemHS.Create(nil);
      if not Map.PlaceHX(HS, X, Y, L) then
      begin
        HS.Free;
        HS := nil;
      end;
    end;
    if HS <> nil then
    begin
      SetOwner(HS.FItems);
      Result := True;
    end
    else Result := False;
  end
  else Result := False;
end;

procedure TItem.EditDropMsg(var Msg: TItemDropMsg);
var X, Y, L: Integer;
begin
  L := Msg.Lhp;
  HPtoHX(Msg.Xhp, Msg.Yhp, X, Y);
  if not PlaceOnMap(AoWHSMap, X, Y, L) then Msg.Result := -1
  else Msg.Result := 0;
end;

procedure TItem.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $10005 then EditDropMsg(TItemDropMsg(Msg));
end;

constructor TItemList.Create(AOwner: TECustomNode);
begin inherited Create(AOwner); end;

function TItemList.RemoveChild(Child: TEObject): Integer;
begin
  Result := inherited RemoveChild(Child);
  if Result <> -1 then Child.Release;
end;

function TItemList.AddChild(Child: TEObject): Integer;
begin
  Result := inherited AddChild(Child);
  if Result <> -1 then Child.AddRef;
end;

procedure TItemList.DestroyAllChildren;
begin
  Clear;
  inherited DestroyAllChildren;
end;

procedure TItemList.MainReadWrite(Stream: TEStorageStream);
var I: Integer;
begin
  inherited MainReadWrite(Stream);
  if Stream.StorageMode * [smRead, smText, smCompare] = [smRead] then
    for I := 0 to FChildren.Count - 1 do
      if FChildren.List^[I] <> nil then TEObject(FChildren.List^[I]).Release;
end;

procedure TItemList.Clear;
var I: Integer; Child: TEObject;
begin
  for I := Count - 1 downto 0 do
    if FChildren.List^[I] <> nil then
    begin
      Child := TEObject(FChildren.List^[I]);
      if Child <> nil then
        if Child.Owner <> Self then
        begin
          Child.Release;
          FChildren.Delete(I);
        end
        else Child.SetOwner(nil);
    end;
  inherited Clear;
end;

procedure TItemList.Changed;
begin
  inherited Changed;
  if Assigned(FOnChanged) then FOnChanged(Self);
end;

function TItemList.FindItem(ItemID: Integer): TItem;
var I: Integer; Item: TItem;
begin
  if Self <> nil then
  begin
    I := 0;
    Result := nil;
    while (I <> FChildren.Count) and (Result = nil) do
    begin
      Item := TItem(FChildren.List^[I]);
      if (Item <> nil) and (ItemID = Item.FItemID) then Result := Item;
      Inc(I);
    end;
  end
  else Result := nil;
end;

function TItemList.GetItem(Index: Integer): TItem;
begin
  if (Index >= 0) and (Index < Count) then Result := TItem(FChildren.List^[Index])
  else Result := nil;
end;

procedure TItemList.Update;
begin SortOnType; end;

procedure TItemList.GetLocation(var X, Y, L: Shortint);
begin X := -1; Y := -1; L := -1; end;

function CompareItemNames(Item1, Item2: Pointer): Integer;
begin
  if (Item1 <> nil) and (Item2 <> nil) then
  begin
    Result := CompareText(TItem(Item1).FOwnerName, TItem(Item2).FOwnerName);
    if Result = 0 then Result := Integer(Item1) - Integer(Item2);
  end
  else Result := 0;
end;

function CompareItemTypes(Item1, Item2: Pointer): Integer;
begin
  { Original type comparison assumes both entries are non-nil. }
  Result := Ord(TItem(Item1).FItemType) - Ord(TItem(Item2).FItemType);
  if Result = 0 then Result := Integer(Item1) - Integer(Item2);
end;

procedure TItemList.SortOnName;
begin FChildren.Sort(CompareItemNames); end;

procedure TItemList.SortOnType;
begin FChildren.Sort(CompareItemTypes); end;

procedure TItemList.RegisterItems;
var I: Integer; Item: TItem;
begin
  for I := FChildren.Count - 1 downto 0 do
  begin
    Item := TItem(FChildren.List^[I]);
    if (Item <> nil) and not (isRegistered in Item.FStatus) then
      AoWHSMap.FItemControl.RegisterItem(Item);
  end;
end;

procedure TItemList.LockChanged;
begin BeginUpdate; end;

procedure TItemList.UnlockChanged;
begin EndUpdate; end;

constructor TItemControl.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FItems := TList.Create;
  FOnChanged := TEventList.Create;
  FOnItemChanged := TEventList.Create;
end;

destructor TItemControl.Destroy;
var I: Integer;
begin
  BeginUpdate;
  for I := FItems.Count - 1 downto 0 do UnRegisterItem(TItem(FItems.List^[I]));
  FItems.Clear;
  Changed;
  FItems.Free;
  FOnItemChanged.Free;
  FOnChanged.Free;
  inherited Destroy;
end;

procedure TItemControl.ReadWrite(Stream: Engine.TEStorageStream);
var ID, I: Integer; Item: TItem;
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FLastID, 9);
  if smCompare in Stream.StorageMode then
  begin
    ID := 10;
    for I := 0 to FItems.Count - 1 do
    begin
      Item := TItem(FItems[I]);
      if Item.Owner = nil then
      begin
        Stream.rwCreateEObject(TEObject(Item), nil, ID);
        Inc(ID);
      end;
    end;
  end
  else if Stream.StorageMode * [smTextOnly, smPreview, smCompare] = [] then
  begin
    if smRead in Stream.StorageMode then
    begin
      ID := 10;
      repeat
        Stream.rwCreateEObject(TEObject(Item), nil, ID);
        if Item <> nil then
        begin
          ValidateItem(Item);
          FItems.Add(Item);
          Item.FStatus := Item.FStatus + [isRegistered];
        end;
        Inc(ID);
      until Item = nil;
    end;
    if (smTextOnly in Stream.StorageMode) or (smWrite in Stream.StorageMode) then
    begin
      ID := 10;
      for I := 0 to FItems.Count - 1 do
        if TItem(FItems.List^[I]).Owner = nil then
        begin
          Stream.rwCreateEObject(TEObject(FItems.List^[I]), nil, ID);
          Inc(ID);
        end;
    end;
  end;
end;

function TItemControl.GetItem(Index: Integer): TItem;
begin
  Result := TItem(FItems.List^[Index]);
end;

function TItemControl.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TItemControl.FindItem(ItemID: Integer): TItem;
var I: Integer;
begin
  I := FItems.Count;
  while I <> 0 do
  begin
    Dec(I);
    if TItem(FItems.List^[I]).FItemID = ItemID then
    begin
      Result := TItem(FItems.List^[I]);
      Exit;
    end;
  end;
  Result := nil;
end;

procedure TItemControl.ItemChanged(Item: TItem);
begin
  FOnItemChanged.TriggerNotifyEvents(Item);
end;

procedure TItemControl.Changed;
begin
  if FUpdateLock = 0 then FOnChanged.TriggerNotifyEvents(Self);
end;

procedure TItemControl.BeginUpdate;
begin
  Inc(FUpdateLock);
end;

procedure TItemControl.EndUpdate;
begin
  Dec(FUpdateLock);
  if FUpdateLock = 0 then Changed;
end;

function TItemControl.CreateUniqueID: Integer;
var I: Integer;
begin
  repeat
    I := 0;
    Inc(FLastID);
    if FLastID > $FFFFFFF then FLastID := 0;
    while (I <> FItems.Count) and (TItem(FItems.List^[I]).FItemID <> FLastID) do Inc(I);
  until I = FItems.Count;
  Result := FLastID;
end;

procedure TItemControl.ValidateItem(Item: TItem);
begin
  if FindItem(Item.FItemID) <> nil then Item.FItemID := CreateUniqueID;
end;

procedure TItemControl.UpdateLibraryItems;
var I: Integer;
begin
  BeginUpdate;
  for I := GetCount - 1 downto 0 do TItem(FItems.List^[I]).UpdateFromLibrary;
  EndUpdate;
end;

procedure TItemControl.RegisterItem(Item: TItem);
var Existing: TItem;
begin
  if not (isRegistered in Item.FStatus) then
  begin
    Existing := FindItem(Item.FItemID);
    if (Existing <> nil) and Existing.Compare(Item, AoWEngine) and
      (Existing.FRefCount = 1) then UnRegisterItem(Existing);
    ValidateItem(Item);
    Item.FStatus := Item.FStatus + [isRegistered];
    FItems.Add(Item);
    Item.AddRef;
    if (icsActivated in FStatus) and not (isActivated in Item.FStatus) then Item.Activate;
    Changed;
  end;
end;

procedure TItemControl.UnRegisterItem(Item: TItem);
begin
  if isRegistered in Item.FStatus then
  begin
    FItems.Remove(Item);
    Item.FStatus := Item.FStatus - [isRegistered];
    Item.Release;
    Changed;
  end;
end;

function TItemControl.GenerateItem(Types: TItemTypes; MinValue, MaxValue: Integer): TItem;
var List: TDoubleItemList; I, Value: Integer; Item: TItem;
begin
  List := TDoubleItemList.Create;
  for I := 0 to GetCount - 1 do
  begin
    Item := TItem(FItems.List^[I]);
    if (Item.FRefCount = 1) and (Item.FItemType in Types) then
    begin
      Value := Item.GetObtainValue;
      if (Value >= MinValue) and (Value <= MaxValue) then
        List.AddAB(Integer(Item), Ord(Item.FAvailability));
    end;
  end;
  if List.Count <> 0 then Result := TItem(List[List.RandomChanceItemB(1)].A)
  else Result := nil;
  List.Free;
end;

function TItemControl.GenerateItems(Types: TItemTypes; Owner: TECustomNode; Value: Integer): Integer;
var
  List: TDoubleItemList;
  I, Difference, Attempts, ItemValue, Distance: Integer;
  Done: Boolean;
  Item, Candidate: TItem;
begin
  Result := 0;
  List := TDoubleItemList.Create;
  for I := 0 to GetCount - 1 do
  begin
    Item := TItem(FItems.List^[I]);
    if (Item.FItemType in Types) and (Item.FRefCount = 1) then
      List.AddAB(Integer(Item), Ord(Item.FAvailability));
  end;
  Done := False;
  while not Done and (List.Count <> 0) do
  begin
    Candidate := TItem(List[List.RandomChanceItemB(1)].A);
    ItemValue := Candidate.GetObtainValue;
    if ItemValue > Value then
    begin
      Attempts := 10;
      Difference := Abs(ItemValue - Value);
      repeat
        Item := TItem(List[List.RandomChanceItemB(1)].A);
        Distance := Abs(Item.GetObtainValue - Value);
        if Distance < Difference then
        begin
          Difference := Distance;
          Candidate := Item;
        end;
        Dec(Attempts);
      until Attempts = 0;
      if Value < Difference then
      begin
        Candidate := nil;
        Done := True;
      end;
    end;
    if Candidate <> nil then
    begin
      Candidate.SetOwner(Owner);
      List.Delete(List.IndexOfItemA(Integer(Candidate)));
      Dec(Value, Candidate.GetObtainValue);
      Inc(Result);
    end;
  end;
  List.Free;
end;

procedure TItemControl.Activate;
var I: Integer;
begin
  if not (icsActivated in FStatus) then
  begin
    FStatus := FStatus + [icsActivated];
    for I := FItems.Count - 1 downto 0 do TItem(FItems.List^[I]).Activate;
  end;
end;

procedure TItemControl.Deactivate;
var I: Integer;
begin
  if icsActivated in FStatus then
  begin
    FStatus := FStatus - [icsActivated];
    for I := FItems.Count - 1 downto 0 do TItem(FItems.List^[I]).Deactivate;
  end;
end;

resourcestring
  SystemItemLibraryRStr = 'System';

function TItemLibrary.CreateUniqueLibraryID: Integer;
var I: Integer;
begin
  repeat
    I := 0;
    Inc(FLastID);
    if FLastID > $FFFFFFF then FLastID := 0;
    while (I <> FChildren.Count) and (TItem(FChildren.List^[I]).FLibraryID <> FLastID) do Inc(I);
  until I = FChildren.Count;
  Result := FLastID;
end;

function TItemLibrary.AddChild(Child: Engine.TEObject): Integer;
begin
  with TItem(Child) do
    { Original checks the world item ID, not the library ID. }
    if (FLibraryID <= 0) or (FindItem(FLibraryID) <> nil) then FLibraryID := CreateUniqueLibraryID;
  Result := inherited AddChild(Child);
end;

function TItemLibrary.FindLibraryID(LibraryID: Integer): TItem;
var I: Integer;
begin
  I := FChildren.Count;
  while I <> 0 do
  begin
    Dec(I);
    if TItem(FChildren.List^[I]).FLibraryID = LibraryID then
    begin
      Result := TItem(FChildren.List^[I]);
      Exit;
    end;
  end;
  Result := nil;
end;

procedure TItemLibrary.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwString(FName, 20);
  Stream.rwInteger(FLastID, 21);
end;

function TItemLibrary.GetName: string;
begin
  Result := FName;
  if Result = '' then Result := TranslateRStr(SystemItemLibraryRStr);
end;

function TItemLibrary.CreateItem: TItem;
var Item: TItem;
begin
  Item := TItem.Create(nil);
  Item.FLibraryID := CreateUniqueLibraryID;
  Item.FLibraryName := FName;
  Item.SetOwner(Self);
  Item.Release;
  Result := Item;
end;

procedure TItemLibrary.LoadFromFile(const FileName: string);
begin
  AoWEngine.ReadFromFile(FileName, Self, nil);
end;

procedure TItemLibrary.SaveToFile(const FileName: string);
begin
  AoWEngine.WriteToFile(FileName, Self, nil);
end;

constructor TItemLibraryManager.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSystemLibrary := TItemLibrary.Create(nil);
  FLibraries := TENode.Create(nil);
end;

destructor TItemLibraryManager.Destroy;
begin
  FLibraries.Free;
  FSystemLibrary.Free;
  inherited Destroy;
end;

procedure TItemLibraryManager.ReadWrite(Stream: Engine.TEStorageStream);
var Directory: string;
begin
  inherited ReadWrite(Stream);
  if Stream.StorageMode * [smTextOnly, smCompare] = [] then
  begin
    Directory := ExtractFilePath(AoWEngine.HSSFileName);
    if smRead in Stream.StorageMode then
    begin
      ReadUserLibraries;
      AoWEngine.ReadFromFile(Directory + 'ITEMS.PFS', FSystemLibrary, nil);
    end
    else
    begin
      AoWEngine.WriteToFile(Directory + 'ITEMS.PFS', FSystemLibrary, nil);
      WriteUserLibraries;
    end;
  end
  else Stream.rwEObject(FSystemLibrary, 20);
end;

function TItemLibraryManager.GetLibrary(Index: Integer): TItemLibrary;
begin
  Result := TItemLibrary(FLibraries.FChildren.EObjects[Index]);
end;

function TItemLibraryManager.GetCount: Integer;
begin
  Result := FLibraries.Count;
end;

procedure TItemLibraryManager.ReadUserLibraries;
var Search: TSearchRec; ItemLibrary: TItemLibrary; Found: Boolean;
begin
  FLibraries.Clear;
  FLibraries.AddChild(FSystemLibrary);
  Found := FindFirst(AoWEngine.StartupDirectory + 'User\' + '*' + '.ail',
    faAnyFile and not faDirectory, Search) = 0;
  while Found do
  begin
    ItemLibrary := TItemLibrary.Create(nil);
    try
      ItemLibrary.LoadFromFile(AoWEngine.StartupDirectory + 'User\' + Search.Name);
      ItemLibrary.SetOwner(FLibraries);
    except
      ItemLibrary.Free;
    end;
    Found := FindNext(Search) = 0;
  end;
  FindClose(Search);
end;

procedure TItemLibraryManager.WriteUserLibraries;
var I: Integer; ItemLibrary: TItemLibrary;
begin
  for I := 1 to FLibraries.Count - 1 do
  begin
    ItemLibrary := GetLibrary(I);
    ItemLibrary.SaveToFile(AoWEngine.StartupDirectory + 'User\' + ItemLibrary.GetName + '.ail');
  end;
end;

function TItemLibraryManager.IndexOfLibraryName(const Name: string): Integer;
begin
  Result := FLibraries.Count;
  while Result <> 0 do
  begin
    Dec(Result);
    if CompareText(Name, TItemLibrary(FLibraries.FChildren.List^[Result]).FName) = 0 then Exit;
  end;
  Result := -1;
end;

function TItemLibraryManager.IndexOfLibrary(ItemLibrary: TItemLibrary): Integer;
begin
  Result := FLibraries.FChildren.IndexOf(ItemLibrary);
end;

function TItemLibraryManager.FindItem(const LibraryName: string; LibraryID: Integer): TItem;
var Index: Integer;
begin
  Index := IndexOfLibraryName(LibraryName);
  if Index <> -1 then
    Result := TItemLibrary(FLibraries.FChildren.List^[Index]).FindLibraryID(LibraryID)
  else Result := nil;
end;

function TItemLibraryManager.CreateLibrary(const Name: string): TItemLibrary;
var LibraryName: string;
begin
  LibraryName := Name;
  { Original retains the period when stripping the extension. }
  if Pos('.', LibraryName) <> 0 then LibraryName := System.Copy(LibraryName, 1, Pos('.', LibraryName));
  if (LibraryName <> '') and (IndexOfLibraryName(LibraryName) = -1) then
  begin
    Result := TItemLibrary.Create(FLibraries);
    Result.FName := LibraryName;
    { Original creates in Release while reading and deleting from User. }
    Result.SaveToFile(AoWEngine.StartupDirectory + 'Release\' + LibraryName + '.ail');
  end
  else Result := nil;
end;

procedure TItemLibraryManager.DeleteLibrary(Index: Integer);
begin
  if (Index < FLibraries.Count) and (Index > 0) then
  begin
    Windows.DeleteFile(PChar(AoWEngine.StartupDirectory + 'User\' + GetLibrary(Index).GetName + '.ail'));
    GetLibrary(Index).Free;
  end;
end;

function TItemGFX.GetEngine: Engine.TEngine;
begin
  Result := AoWEngine;
end;

class function TItemGFX.ClassID: Integer;
begin
  Result := $20269;
end;

function TItemGFX.ItemGFXIndex: Integer;
begin
  Result := Owner.FindChildIndex(Self);
end;

procedure TItemGFX.LinkToIL;
begin
  ReleaseIL;
  if FImageLibraryName <> '' then
    FImageLibrary := AoWHSSet.ImageLibraryManager.LinkToIL([icDisk], FImageLibraryName)
  else FImageLibrary := nil;
end;

procedure TItemGFX.ReleaseIL;
begin
  if FImageLibrary <> nil then
  begin
    if FImageLibraryName <> '' then
      AoWHSSet.ImageLibraryManager.ReleaseIL([icDisk], FImageLibraryName);
    FImageLibrary := nil;
  end;
end;

procedure TItemGFX.SetImageLibraryName(Value: string);
begin
  if FImageLibraryName <> '' then
  begin
    AoWHSSet.ImageLibraryManager.ReleaseIL([icDisk], FImageLibraryName);
    FImageLibrary := nil;
  end;
  FImageLibraryName := Value;
  if (FImageLibraryName <> '') and (FRefCount <> 0) then
    FImageLibrary := AoWHSSet.ImageLibraryManager.LinkToIL([icDisk], FImageLibraryName);
end;

function TItemGFX.AddRef: Integer;
begin
  if FRefCount = 0 then LinkToIL;
  Inc(FRefCount);
  Result := FRefCount;
end;

function TItemGFX.Release: Integer;
begin
  Dec(FRefCount);
  if FRefCount = 0 then ReleaseIL;
  Result := FRefCount;
end;

function TItemGFX.GetCellImage: ImageLib.TLibraryImage;
var Image: TLibraryImage;
begin
  AddRef;
  Image := FImageLibrary[FImageIndex];
  Release;
  Result := Image;
end;

function TItemGFX.GetItemImage: TLibraryImage;
begin
  if FImageLibrary <> nil then Result := FImageLibrary[FImageIndex]
  else Result := nil;
end;

procedure TItemGFX.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  if not (smTextOnly in Stream.StorageMode) then Stream.rwString(FImageLibraryName, 6);
  Stream.rwInteger(FImageIndex, 7);
  Stream.rwData(FItemType, 1, 8);
  Stream.rwBool(FHidden, 9);
end;

constructor TItemGFXList.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  SetControlStyle([csSaveLoad, csFixedChild, csArrayMode]);
end;

function TItemGFXList.GetItemGFX(Index: Integer): TItemGFX;
begin
  if (Index >= 0) and (Index < FChildren.Count) then
    Result := TItemGFX(FChildren.List^[Index])
  else Result := nil;
end;

function TItemGFXList.FindItemTypeGFX(ItemType: TItemType): Integer;
var I: Integer;
begin
  Result := -1;
  I := 0;
  while (Result = -1) and (I <> FChildren.Count) do
  begin
    if (FChildren.List^[I] <> nil) and
      (TItemGFX(FChildren.List^[I]).FItemType = ItemType) then Result := I;
    Inc(I);
  end;
end;

procedure TItemHSList.SetOwner(AOwner: Engine.TECustomNode);
begin
  FOwner := AOwner;
end;

procedure TItemHSList.GetLocation(var X, Y, L: Shortint);
begin
  X := TItemHS(Owner).Xhx;
  Y := TItemHS(Owner).Yhx;
  L := TItemHS(Owner).Lhx;
end;

resourcestring
  ItemBagRStr = 'Item Bag';

constructor TItemHS.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FItems := TItemHSList.Create(TECustomNode(Self));
  FItems.FOnChanged := ItemsChanged;
end;

destructor TItemHS.Destroy;
begin
  inherited Destroy;
  FItems.Free;
  FItems := nil;
end;

procedure TItemHS.ItemsChanged(Sender: TObject);
begin
  if (FItems.Count = 0) and ((FGenerateMode = igUserDefined) or (AoWHSMap.FDay > 0)) then
    Destroy
  else Changed;
end;

function TItemHS.GetLevel: Byte;
begin
  Result := 26;
end;

function TItemHS.GetShowPriority: Integer;
var Xhp, Yhp: Integer; HS: THexagonSprite;
begin
  HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhp, Yhp);
  Result := $68000000 + (Yhp + 33) * $2000 + (Xhp + 16);
  HS := TMapField(Owner).GetMaxLevelNoneTransparentHS;
  if (Self <> HS) and (HS <> nil) then
    if Result <= HS.GetShowPriority then Result := HS.GetShowPriority + 1;
end;

class function TItemHS.ClassID: Integer;
begin
  Result := $20271;
end;

function TItemHS.EditName: string;
begin
  Result := TranslateRStr(ItemBagRStr);
end;

function TItemHS.CanSelect(Xhp, Yhp: Integer): Boolean;
begin
  if (WordRec(LongRec(TAoWMapField(Owner).FFieldFlags).Hi).Lo = 0) and
    (AoWHSMap.FFogEnabled <> 0) then Result := False
  else Result := True;
end;

procedure TItemHS.Activate;
begin
  inherited Activate;
  FItems.RegisterItems;
end;

procedure TItemHS.Deactivate;
begin
  inherited Deactivate;
end;

procedure TItemHS.ReadWrite(Stream: Engine.TEStorageStream);
begin
  FItems.BeginUpdate;
  inherited ReadWrite(Stream);
  Stream.rwEObject(FItems, 4);
  Stream.rwData(FGenerateMode, 1, 5);
  FItems.EndUpdate;
end;

procedure TItemHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var Xhp, Yhp: Integer;
begin
  if not GetSelected or (AoWHSMap.Frame and 6 <> 6) then
  begin
    HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhp, Yhp);
    AoWHSSet.FGeneralImages[0].Show(Xhp - XhpSurf, Yhp - YhpSurf, SurfaceDesc);
  end;
end;

function TItemHS.CanPlace(Map: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin
  Result := inherited CanPlace(Map, Xhx, Yhx, Lhx);
end;

procedure TItemHS.GenerateItems;
var I: Byte; Item: TItem;
begin
  if FGenerateMode <> igUserDefined then
  begin
    RandSeed := AoWHSMap.Random($FFFFFF);
    FItems.FOnChanged := nil;
    if FGenerateMode = igRandom then FGenerateMode := TItemGenerateMode(AoWHSMap.Random(3) + 1);
    FItems.Clear;
    for I := 1 to Ord(FGenerateMode) do
    begin
      Item := AoWHSMap.FItemControl.GenerateItem([itHead, itTorso, itAttack, itDefense, itRing, itUse], 0, $FFFF);
      if Item <> nil then Item.SetOwner(FItems);
    end;
    FItems.FOnChanged := ItemsChanged;
    ItemsChanged(FItems);
  end;
end;

procedure TItemHS.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if (Msg.MsgID = $20020001) and (AoWHSMap.FDay = 1) then GenerateItems;
end;

procedure TWorldFXHS.Deactivate;
begin
  AoWHSMap.NewFrameEvents.Remove(NewFrame);
  inherited Deactivate;
end;

constructor TWorldFXHS.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FPath := TXYZList.Create;
  FFrame := -1;
end;

destructor TWorldFXHS.Destroy;
begin
  FPath.Free;
  inherited Destroy;
end;

procedure TWorldFXHS.Activate;
begin
  inherited Activate;
  AoWHSMap.NewFrameEvents.Add(NewFrame);
  FFrame := -1;
end;

function TWorldFXHS.GetShowPriority: Integer;
begin
  Result := $6C000000;
end;

procedure TWorldFXHS.NewFrame(Sender: TObject);
var Effect: TWorldFXHS; I, J, Count, RadiusX, RadiusY: Integer; Gravity, VZ, Speed, Z: Single;
begin
  try
    Inc(FFrame);
    case FEffectType of
      fxHatred:
        case FFrame of
          0..89:
            if FFrame mod 3 = 0 then
            begin
              RadiusX := 200;
              RadiusY := 200;
              for I := 0 to 29 do
              begin
                Effect := AoWHSMap.AddEffect(fxHatredParticle);
                Effect.FX := 50;
                Effect.FY := 50;
                RadiusX := -RadiusX;
                MakeLinePath(0, 0, Round(Cos((Random(12) + I * 12 + FFrame * 4) * Pi / 180) * (RadiusX + Random(10))),
                  Round(Sin((I * 6 + FFrame * 4) * Pi / 180) * (RadiusY + Random(10))) div 2, 75, Effect.FPath);
              end;
            end;
          90: FFrame := -1;
        end;
      fxTranquility:
        case FFrame of
          0..89:
            if FFrame mod 3 = 0 then
            begin
              RadiusX := 200;
              RadiusY := 200;
              for I := 0 to 29 do
              begin
                Effect := AoWHSMap.AddEffect(fxTranqParticle);
                Effect.FX := 50;
                Effect.FY := 50;
                RadiusX := -RadiusX;
                MakeLinePath(0, 0, Round(Cos((Random(12) + I * 12 + FFrame * 4) * Pi / 180) * (RadiusX + Random(10))),
                  Round(Sin((I * 6 + FFrame * 4) * Pi / 180) * (RadiusY + Random(10))) div 2, 75, Effect.FPath);
              end;
            end;
          90: FFrame := -1;
        end;
      fxCrusade:
        case FFrame of
          0..74:
            if FFrame mod 3 = 0 then
            begin
              RadiusX := 150;
              RadiusY := 150;
              for I := 0 to 59 do
              begin
                Effect := AoWHSMap.AddEffect(fxWMLParticle);
                Effect.FLayer := FLayer;
                RadiusX := -RadiusX;
                MakeLinePath(FX, FY, FX + Round(Cos((I * 6 + FFrame * 4) * Pi / 180) * (RadiusX + Random(10))),
                  FY + Round(Sin((I * 6 + FFrame * 4) * Pi / 180) * (RadiusY + Random(10))) div 2, 50, Effect.FPath);
              end;
            end;
          75: FFrame := -1;
        end;
      fxWaterMastery:
        case FFrame of
          0..199:
            begin
              if FFrame mod 5 = 0 then
              begin
                AoWHSSet.FSpellControl.GetSpell(45).FCastSounds.Play(1);
                Count := Random(10) + 100;
                for J := 0 to Count do
                begin
                  Effect := AoWHSMap.AddEffect(fxWMParticle);
                  Effect.FX := 50;
                  Effect.FY := 50;
                  Speed := (Random(50) + 50) * 0.1;
                  Gravity := 0.1;
                  VZ := (Random(5) + 5) * 0.1;
                  Z := 0;
                  MakeArcPath(0, 0, Random(360), Z, Speed, VZ, Gravity, Effect.FPath);
                end;
              end;
              for J := 0 to 1 do
              begin
                Count := Random(3) + 7;
                for I := 1 to Count - 1 do
                begin
                  Effect := AoWHSMap.AddEffect(fxWMParticle);
                  Effect.FX := 50 + Round(Cos(FFrame * 360 * 0.01 * Pi / 180) * FFrame) div 4;
                  Effect.FY := 50 + Round(Sin(FFrame * 360 * 0.01 * Pi / 180) * FFrame) div 8;
                  if J = 1 then
                  begin Effect.FX := 100 - Effect.FX; Effect.FY := 100 - Effect.FY; end;
                  Speed := (Random(10) + 30) * 0.1;
                  Gravity := 0.5;
                  VZ := (Random(50) + FFrame div 2) * 0.1;
                  Z := 0;
                  MakeArcPath(0, 0, I * 360 div Count, Z, Speed, VZ, Gravity, Effect.FPath);
                end;
              end;
            end;
          200: FFrame := -1;
        end;
      fxSpellWard:
        begin
          case FFrame of
            0..14:
              begin
                RadiusX := 200;
                RadiusY := 200;
                for I := 0 to 29 do
                begin
                  Effect := AoWHSMap.AddEffect(fxSWParticle);
                  Effect.FX := 50;
                  Effect.FY := 50;
                  RadiusX := -RadiusX;
                  MakeArcPathXY(Round(Cos((I * 12 + FFrame * 5) * Pi / 180) * (RadiusX + Random(10))),
                    Round(Sin((I * 12 + FFrame * 5) * Pi / 180) * (RadiusY + Random(10))) div 2,
                    0, -150, 100, 10, Effect.FPath);
                  for J := 0 to Effect.FPath.Count - 1 do
                    Effect.FPath[J].Z := -Effect.FPath[J].Z;
                end;
              end;
          end;
          case FFrame of
            15..44:
              if FFrame mod 5 = 0 then
              begin
                Count := Random(10) + 100;
                for J := 0 to Count do
                begin
                  Effect := AoWHSMap.AddEffect(fxSWBeamParticle);
                  Effect.FX := 50;
                  Effect.FY := 50;
                  Speed := (Random(50) + 50) * 0.1;
                  Gravity := 0.1;
                  VZ := (Random(5) + 5) * 0.1;
                  Z := 0;
                  MakeArcPath(0, -150, Random(360), Z, Speed, VZ, Gravity, Effect.FPath);
                end;
              end;
            120: FFrame := -1;
          end;
        end;
      fxWMParticle, fxWMLParticle, fxHatredParticle, fxSWParticle, fxSWBeamParticle, fxEMParticle, fxTranqParticle:
        if FFrame >= FPath.Count - 1 then
        begin FFrame := FPath.Count - 1; FDone := True; end;
      fxEarthMastery:
        case FFrame of
          0..49:
            for I := 0 to 29 do
            begin
              Effect := AoWHSMap.AddEffect(fxEMParticle);
              RadiusX := Random(12);
              Effect.FX := Round(Cos((I * 12 + RadiusX) * Pi / 180) * 150) + 50;
              Effect.FY := Round(Sin((I * 12 + RadiusX) * Pi / 180) * 150) div 2 + 50;
              MakeLinePath(0, 0, 0, FFrame * 3 - 200, 30, Effect.FPath);
            end;
          200: FFrame := -1;
        end;
    end;
    if FFrame = -1 then FDone := True;
  except
    MessageBox(0, PChar('Error - WorldfxHS ' + IntToStr(Ord(FEffectType))), 'Error during NewFrame', 0);
  end;
end;

procedure TWorldFXHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var Sequence: TImageSequence; Frame: Integer;
  procedure ShowGlobal(Shadow, Inverse: Boolean);
  var Brightness: Integer;
  begin
    Brightness := 100 - FFrame * 100 div FPath.Count - ((FFrame mod 10 * 2 + Integer(Self)) mod 20);
    if Brightness < 0 then Brightness := 0;
    if Shadow then Inc(Brightness, 20);
    if Brightness > 100 then Brightness := 100;
    while Sequence <> nil do
    begin
      { Original uses the instance address as the animation phase. }
      Frame := Sequence.GetUnloopedFrameIndex(Integer(Self) mod 3);
      if Frame <> -1 then
        if Shadow then
        begin
          if Sequence.ImageLibrary.ImageExist(Frame) then
            Sequence.ImageLibrary[Frame].ShowBlended(FPath[FFrame].X + (SurfaceDesc.Width * FX div 100 + Sequence.dXshift),
              FPath[FFrame].Y + (SurfaceDesc.Height * FY div 100 + Sequence.dYshift) - FPath[FFrame].Z,
              SurfaceDesc, ShadowBlendTable.LookupTables[Brightness]);
        end
        else if Inverse then
        begin
          if Sequence.ImageLibrary.ImageExist(Frame) then
            Sequence.ImageLibrary[Frame].ShowBlended(FPath[FFrame].X + (SurfaceDesc.Width * FX div 100 + Sequence.dXshift),
              FPath[FFrame].Y + (SurfaceDesc.Height * FY div 100 + Sequence.dYshift) - FPath[FFrame].Z,
              SurfaceDesc, IntensityBlendTable.LookupTables[100 - Brightness]);
        end
        else if Sequence.ImageLibrary.ImageExist(Frame) then
          Sequence.ImageLibrary[Frame].ShowBlended(FPath[FFrame].X + (SurfaceDesc.Width * FX div 100 + Sequence.dXshift),
            FPath[FFrame].Y + (SurfaceDesc.Height * FY div 100 + Sequence.dYshift) - FPath[FFrame].Z,
            SurfaceDesc, IntensityBlendTable.LookupTables[Brightness]);
      Sequence := Sequence.Next;
    end;
  end;
  procedure ShowLocal(Shadow: Boolean);
  var Brightness: Integer;
  begin
    Brightness := 100 - FFrame * 100 div FPath.Count - ((FFrame mod 10 * 2 + Integer(Self)) mod 20);
    if Brightness < 0 then Brightness := 0;
    if Shadow then Inc(Brightness, 20);
    if Brightness > 100 then Brightness := 100;
    while Sequence <> nil do
    begin
      Frame := Sequence.GetUnloopedFrameIndex(Integer(Self) mod 3);
      if Frame <> -1 then
        if Shadow then
        begin
          if Sequence.ImageLibrary.ImageExist(Frame) then
            Sequence.ImageLibrary[Frame].ShowBlended(FPath[FFrame].X + Sequence.dXshift - XhpSurf,
              FPath[FFrame].Y + Sequence.dYshift - FPath[FFrame].Z - YhpSurf,
              SurfaceDesc, ShadowBlendTable.LookupTables[Brightness]);
        end
        else if Sequence.ImageLibrary.ImageExist(Frame) then
          Sequence.ImageLibrary[Frame].ShowBlended(FPath[FFrame].X + Sequence.dXshift - XhpSurf,
            FPath[FFrame].Y + Sequence.dYshift - FPath[FFrame].Z - YhpSurf,
            SurfaceDesc, IntensityBlendTable.LookupTables[Brightness]);
      Sequence := Sequence.Next;
    end;
  end;
begin
  try
    if FFrame >= 0 then
      case FEffectType of
        fxWMParticle:
          begin Sequence := AoWHSSet.FSpellControl.GetSpell(45).FCastImages.GetImageSequence(0); ShowGlobal(False, False); end;
        fxWMLParticle:
          if AoWHSMap.ViewL = FLayer then
          begin Sequence := AoWHSSet.FSpellControl.GetSpell(75).FCastImages.GetImageSequence(1); ShowLocal(False); end;
        fxHatredParticle:
          begin Sequence := AoWHSSet.FSpellControl.GetSpell(46).FCastImages.GetImageSequence(0); ShowGlobal(True, False); end;
        fxSWParticle:
          begin Sequence := AoWHSSet.FSpellControl.GetSpell(65).FCastImages.GetImageSequence(1); ShowGlobal(False, True); end;
        fxSWBeamParticle:
          begin Sequence := AoWHSSet.FSpellControl.GetSpell(65).FCastImages.GetImageSequence(1); ShowGlobal(False, False); end;
        fxEMParticle:
          begin Sequence := AoWHSSet.FSpellControl.GetSpell(64).FCastImages.GetImageSequence(0); ShowGlobal(False, False); end;
        fxTranqParticle:
          begin Sequence := AoWHSSet.FSpellControl.GetSpell(47).FCastImages.GetImageSequence(0); ShowGlobal(False, False); end;
      end;
  except
    MessageBox(0, PChar('Error - WorldfxHS ' + IntToStr(Ord(FEffectType))), 'Error during Show', 0);
  end;
end;

procedure TTranslateTextStream.TranslateString(var S: string);
begin
  S := FDictionary.Translate(S);
end;

procedure TTranslateTextStream.TranslateStrings(var Strings: Classes.TStrings);
var S: string; I, EndOfLine, LineFeed: Integer;
begin
  if Strings.Count <> 0 then
  begin
    S := '';
    for I := 0 to Strings.Count - 1 do
    begin
      S := S + Strings[I];
      if I <> Strings.Count - 1 then S := S + '<eol>';
    end;
    S := FDictionary.Translate(S);
    Strings.Clear;
    repeat
      EndOfLine := Pos('<eol>', S);
      LineFeed := Pos(#10, S);
      if ((EndOfLine < LineFeed) or (LineFeed = 0)) and (EndOfLine <> 0) then
      begin
        Strings.Add(Copy(S, 1, EndOfLine - 1));
        S := Copy(S, EndOfLine + 5, Length(S) - EndOfLine - 4);
      end
      else if ((LineFeed < EndOfLine) or (EndOfLine = 0)) and (LineFeed <> 0) then
      begin
        Strings.Add(Copy(S, 1, LineFeed - 1));
        { Original reverses the length comparison before reading the following CR. }
        if (Length(S) < LineFeed + 1) and (S[LineFeed + 1] = #13) then Inc(LineFeed);
        S := Copy(S, LineFeed + 1, Length(S) - LineFeed);
      end
      else
      begin Strings.Add(S); S := ''; end;
    until S = '';
  end;
end;

procedure TAoWEngine.TranslateEObject(Obj: TEObject; Dictionary: TIvDictionary);
var Stream: TTranslateTextStream;
begin
  Stream := TTranslateTextStream.Create(Self);
  Stream.FDictionary := Dictionary;
  try
    Stream.rwEObject(Obj, 0);
  finally
    Stream.Free;
  end;
end;

procedure TAoWEngine.TranslateEObjectFromFile(Obj: TEObject; const FileName: string);
var Dictionary: TAoWDictionary;
begin
  if FileExists(FileName) then
  begin
    Dictionary := TAoWDictionary.Create(nil);
    try
      Dictionary.FFileName := FileName;
      Dictionary.Open;
      case FRegistry.GetLanguage of
        alAuto: Dictionary.SetLanguage(-1);
        alEnglish: Dictionary.SetLanguage(1);
        alGerman: Dictionary.SetLanguage(2);
        alFrench: Dictionary.SetLanguage(3);
        alSpanish: Dictionary.SetLanguage(5);
        alItalian: Dictionary.SetLanguage(4);
      end;
      TranslateEObject(Obj, Dictionary);
      Dictionary.Close;
    finally
      Dictionary.Free;
    end;
  end;
end;

procedure TAoWEngine.ExportTextToFile(const FileName: string; Obj: TEObject);
var FileStream: TFileStream; Stream: TExportTextStream;
begin
  FileStream := TFileStream.Create(FileName, fmCreate);
  try
    Stream := TExportTextStream.Create(FileStream, Self);
    try
      Stream.rwEObject(Obj, 0);
    finally
      Stream.Free;
    end;
  finally
    FileStream.Free;
  end;
end;

resourcestring
  P2UndeadPluralRStr = 'Undead(plural)';
  P2UndeadRStr = 'Undead';

function TAoWEngine.TranslateRStr(const S: string): string;
begin
  if FDictionary.FLanguage > 0 then Result := FDictionary.Translate(S)
  else if CompareText(S, P2UndeadPluralRStr) = 0 then Result := P2UndeadRStr
  else Result := S;
end;

function TAoWEngine.TranslateText(const Text: string): string;
begin
  Result := TranslateRStr(Text);
end;

const
  P2MovementTemplates: array[0..7] of TMovePointTable = (
  (
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, 6, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 6, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 6, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 6, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 6, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, -1, -1, -1, 3, 3, -1, 3, -1, -1, -1, 8, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, -1, -1, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 6, -1, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, -1, -1, -1, -1, -1, -1, 3, -1, -1, -1, 8, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1)
  ),
  (
    (4, -1, -1, -1, 4, -1, -1, 4, 4, -1, 4, -1, 8, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, -1, -1, 4, -1, -1, 4, 4, -1, 4, -1, 8, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, -1, -1, 4, -1, -1, 4, 4, -1, 4, -1, 8, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1)
  ),
  (
    (4, -1, -1, -1, 4, -1, 4, 4, 4, 4, 4, -1, 4, 4, -1, -1),
    (4, 8, 4, 4, 4, 4, -1, 4, 4, 4, 4, -1, 4, 4, -1, -1),
    (4, 8, 4, 4, 4, 4, -1, 4, 4, 4, 4, -1, 4, 4, -1, -1),
    (4, 8, 4, 4, 4, 4, -1, 4, 4, 4, 4, -1, 4, 4, -1, -1),
    (4, 8, 4, 4, 4, 4, -1, 4, 4, 4, 4, -1, 4, 4, -1, -1),
    (4, 8, 4, 4, 4, 4, -1, 4, 4, 4, 4, -1, 4, 4, -1, -1),
    (4, -1, -1, -1, -1, 4, 4, -1, 4, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, -1, -1, 4, -1, 4, 4, 4, -1, 4, -1, 4, 4, -1, -1),
    (4, -1, -1, -1, 4, 4, 4, 4, 4, -1, 4, -1, 4, 4, -1, -1),
    (4, -1, -1, -1, 4, 4, -1, 4, 4, -1, 4, -1, 4, 4, -1, -1),
    (4, -1, 4, -1, 4, 4, -1, 4, 4, -1, 4, -1, 4, 4, -1, -1),
    (4, -1, -1, -1, -1, -1, -1, -1, 4, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, -1, -1, 4, -1, 4, 4, 4, -1, 4, -1, 4, 4, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1)
  ),
  (
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, 4, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 4, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 4, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 4, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 4, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, -1, -1, -1, 3, 3, -1, 3, -1, -1, -1, 8, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, -1, -1, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 4, -1, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, -1, -1, -1, -1, -1, -1, 3, -1, -1, -1, 8, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1)
  ),
  (
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, 6, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 6, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 6, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 6, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 6, 6, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, -1, -1, -1, 3, 3, -1, 3, -1, -1, -1, 8, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, -1, -1, 4, 3, -1, 6, 3, -1, 4, -1, 8, -1, -1, -1),
    (3, -1, 6, -1, 3, 3, -1, 4, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, -1, -1, -1, -1, -1, -1, 3, -1, -1, -1, 8, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1)
  ),
  (
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, 8, 6, 4, 4, 3, -1, 4, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, 8, 6, 4, 4, 3, -1, 4, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, 8, 6, 4, 4, 3, -1, 4, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, 8, 6, 4, 4, 3, -1, 4, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, 8, 6, 4, 4, 3, -1, 4, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, -1, -1, -1, 3, 3, -1, 3, -1, -1, -1, 8, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, -1, -1, 4, 3, -1, 4, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, 6, -1, 4, 3, -1, 4, 3, -1, 4, -1, 8, -1, -1, -1),
    (4, -1, -1, -1, -1, -1, -1, -1, 3, -1, -1, -1, 8, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1)
  ),
  (
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1)
  ),
  (
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1),
    (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1)
  ));
var
  CombatDID, TMPDID, MAGICDID: Integer;

constructor TAoWEngine.Create(AOwner: Engine.TECustomNode);
var Mask, Terrain, Overlay, MoveType, Points: Integer;
const MoveBits: array[0..7] of Byte = (1, 4, 2, 8, 16, 32, 64, 128);
begin
  AoWEngine := Self;
  SetVersion(1, 36, 53);
  FRegistry := TAoWRegistry.Create;
  FUser := [euProgrammer, euDesigner, euUser];
  FillChar(MovePointTables, SizeOf(MovePointTables), $FF);
  for Mask := 0 to 255 do
    for Overlay := -1 to 11 do
      for Terrain := 0 to 15 do
      begin
        Points := 127;
        for MoveType := 0 to 7 do
          if (Mask and MoveBits[MoveType] <> 0) and (P2MovementTemplates[MoveType,Terrain,Overlay] <> -1) and
            (P2MovementTemplates[MoveType,Terrain,Overlay] < Points) then Points := P2MovementTemplates[MoveType,Terrain,Overlay];
        if Points <> 127 then MovePointTables[Mask,Terrain,Overlay] := Points;
      end;
  FDebug := FRegistry.GetDebugMode;
  FAnimationDetail := Byte(FRegistry.GetDetailLevel);
  FEmailGames := TEmailGameControl.Create(nil);
  FDictionary := TAoWDictionary.Create(nil);
  FDictionary.SetDictionaryName('ResourceStringDictionary');
  { Original selects English for every explicit language here. }
  case FRegistry.GetLanguage of
    alAuto: FDictionary.SetLanguage(-1);
    alEnglish: FDictionary.SetLanguage(1);
    alGerman: FDictionary.SetLanguage(1);
    alFrench: FDictionary.SetLanguage(1);
    alSpanish: FDictionary.SetLanguage(1);
    alItalian: FDictionary.SetLanguage(1);
  end;
  FDemo := False;
  FLanguage := Byte(FRegistry.GetLanguage);
  inherited Create(AOwner);
  Options := Options - [emVerifyEObjects];
  RegisterEClasses([TAoWHSSet, TAoWHSMap, TAoWMapLevel, TAoWCampaign, TAoWCampaignScenario]);
  RegisterEClasses([TPlayer, TRace, TUnit, TRaceResource, TUnitGFXResource, TUnitResource, TUnitHS]);
  RegisterEClasses([THero, THeroResource, THeroUpgradeTE, THeroJoinEventLog, THeroEmergeEventLog, TLeader, TItemGFX, TItem, TItemTE, TItemHS, TFaceResource]);
  RegisterEClasses([TArmy, TArmyHS, TArmyView, TArmyEventLog, TArmyID, TTurnInfoItem, TShowMessageEventLog]);
  RegisterEClasses([TArmyDefaultMoveTE, TArmyCombatMoveTE, TArmyCombineMoveTE, TArmyNegotiateMoveTE, TNegotiateTE, TSaveGameTE, TChangePlayerMagicTE, TChangeGlobalMagicTE]);
  RegisterEClasses([TCombatLogbook, TCombatParty, TCombatData, TDamageCA, TDamageEffectCA, TFleeCA, TCombatUnit]);
  RegisterEClasses([TFastCombat, TCombatWall, TFastCombatUnit, TMoveWallCA, TProductionEventLog]);
  RegisterEClasses([TUpdateHeaderCA, TNewCombatTurnCA, TNewCombatRoundCA, TCombatObjectTurnDoneCA]);
  RegisterEClasses([TCombatEventLog, TCombatPlayer, TDiplomaticAction, TEmailGame, TRestartGameEventLog]);
  RegisterEClasses([TStructure, TStructureResource, TStructureTE, TConstructStructureTE, TProductionTE, THeroUpdateTE]);
  RegisterEClasses([TPlayerStructure, TPlayerStructureResource, TProductionItem, TUnitProduction]);
  RegisterEClasses([TFire, TFireResource]);
  RegisterEClasses([TNewDayEventLog, TArmyInfoEventLog, TTextControlItem, THeroUpgradeEventLog]);
  RegisterEClasses([TDiplomaticActionTE, TDiplomaticActionEventLog, TPlayerMagicEventLog, TDiplomaticRelationHistoryItem, TDiplomaticRelationHistoryList]);
  RegisterEClasses([THuntAG, TAIBudget, TAISavingsBudget, TAITransporterBudget]);
  RegisterEClasses([TGuardGC, TPassiveGC, TGuardAreaGC, TSuicidalGC, TPatrolGC, TScoutGC, TRefugeGC]);
  RegisterSoundEngineClasses(Self);
  RegisterNetworkEngine(Self);
  RegisterEClasses([TEndTurnTE, TGameOverTE, TMultiMoveTE, TCheatTE, TDisbandUnitTE, TChangePlayerSettingsTE, TCombatFlowControlTE, TTerminatePlayerTE]);
  RegisterEventLog(Self);
  RegisterEClasses([TCosmeticSurgeryEnchantment, TLeadershipAbilityData, TDispelMagicAbilityCA]);
  RegisterEClasses([TDurationAbilityData, TMultiLevelAbilityData, TRangedAttackCA, TSelfDestructCA, TStrikeCA]);
  RegisterEClasses([TUnitEnchantmentAbilityData, TUnitEnchantment, TDispelMagicAbilityTE, TPossessedAbilityData]);
  RegisterEClasses([TCommandCA, TCommandedAbilityData, TCommandAbilityData, THealingTE, TDispelMagicAbilityData]);
  RegisterEClasses([TPossessCA, TWebCA, THealingCA, TEntangleCA, THealingAbilityData, TTurnUndeadCA, TInvokeDeathCA]);
  FGameSet.FAbilityControl.RegisterAbility(TLeadershipAbility.Create(nil));
  FGameSet.FAbilityControl.RegisterAbility(TEntangleAbility.Create(nil));
  FGameSet.FAbilityControl.RegisterAbility(TWebAbility.Create(nil));
  FGameSet.FAbilityControl.RegisterAbility(TSelfDestructAbility.Create(nil));
  FGameSet.FAbilityControl.RegisterAbility(TRoundAttackAbility.Create(nil));
  FGameSet.FAbilityControl.RegisterAbility(TCharmAbility.Create(nil));
  FGameSet.FAbilityControl.RegisterAbility(TCharmedAbility.Create(nil));
  FGameSet.FAbilityControl.RegisterAbility(TDominateAbility.Create(nil));
  FGameSet.FAbilityControl.RegisterAbility(TDominatedAbility.Create(nil));
  FGameSet.FAbilityControl.RegisterAbility(TSeduceAbility.Create(nil));
  FGameSet.FAbilityControl.RegisterAbility(TSeducedAbility.Create(nil));
  FGameSet.FAbilityControl.RegisterAbility(THealingAbility.Create(nil));
  FGameSet.FAbilityControl.RegisterAbility(TSpellCastingAbility.Create(nil));
  FGameSet.FAbilityControl.RegisterAbility(TTurnUndeadAbility.Create(nil));
  FGameSet.FAbilityControl.RegisterAbility(TInvokeDeathAbility.Create(nil));
  FGameSet.FAbilityControl.RegisterAbility(TConstructAbility.Create(nil));
  FGameSet.FAbilityControl.RegisterAbility(TDispelMagicAbility.Create(nil));
  FGameSet.FAbilityControl.RegisterAbility(TWallCrushingAbility.Create(nil));
  FGameSet.FAbilityControl.RegisterAbility(TTransportAbility.Create(nil));
  FGameSet.FAbilityControl.RegisterAbility(TPossessAbility.Create(nil));
  FGameSet.FAbilityControl.RegisterAbility(TPossessedAbility.Create(nil));
  RegisterEClasses([TSpellTE]);
  RegisterEClasses([TSpellCastEventLog]);
  RegisterEClasses([TUnitSpellTE, TUnitSpellCA]);
  CombatDID := RegisterDebugID('Combat');
  AIDID := RegisterDebugID('AI');
  TMPDID := RegisterDebugID('TMP');
  MAGICDID := RegisterDebugID('MAGIC');
  Editors.RegisterClass(TAoWMapObjectEditor);
  LoadExternalPlugIns(StartupDirectory + 'PLUGINS');
  FEmailGames.Load;
end;

destructor TAoWEngine.Destroy;
begin
  CloseCampaign;
  CloseHSM(nil);
  UnregisterEClasses([TSpellTE]);
  UnregisterEClasses([TSpellCastEventLog]);
  UnregisterEClasses([TUnitSpellTE, TUnitSpellCA]);
  FGameSet.FSpellControl.UnregisterAll;
  UnregisterEClasses([TCosmeticSurgeryEnchantment, TLeadershipAbilityData]);
  UnregisterEClasses([TDurationAbilityData, TMultiLevelAbilityData, TRangedAttackCA, TSelfDestructCA, TStrikeCA, TDispelMagicAbilityCA]);
  UnregisterEClasses([TUnitEnchantmentAbilityData, TUnitEnchantment, TDispelMagicAbilityTE]);
  UnregisterEClasses([TCommandCA, TCommandedAbilityData, TCommandAbilityData, THealingTE, TDispelMagicAbilityData]);
  UnregisterEClasses([TPossessCA, TWebCA, THealingCA, TEntangleCA, THealingAbilityData, TInvokeDeathCA]);
  FGameSet.FAbilityControl.UnregisterAbilityID(86);
  FGameSet.FAbilityControl.UnregisterAbilityID(87);
  FGameSet.FAbilityControl.UnregisterAbilityID(88);
  FGameSet.FAbilityControl.UnregisterAbilityID(89);
  FGameSet.FAbilityControl.UnregisterAbilityID(90);
  FGameSet.FAbilityControl.UnregisterAbilityID(114);
  FGameSet.FAbilityControl.UnregisterAbilityID(40);
  FGameSet.FAbilityControl.UnregisterAbilityID(27);
  FGameSet.FAbilityControl.UnregisterAbilityID(65);
  FGameSet.FAbilityControl.UnregisterAbilityID(148);
  FGameSet.FAbilityControl.UnregisterAbilityID(149);
  FGameSet.FAbilityControl.UnregisterAbilityID(28);
  FGameSet.FAbilityControl.UnregisterAbilityID(150);
  FGameSet.FAbilityControl.UnregisterAbilityID(29);
  FGameSet.FAbilityControl.UnregisterAbilityID(48);
  FGameSet.FAbilityControl.UnregisterAbilityID(22);
  FGameSet.FAbilityControl.UnregisterAbilityID(47);
  FGameSet.FAbilityControl.UnregisterAbilityID(46);
  FGameSet.FAbilityControl.UnregisterAbilityID(52);
  FGameSet.FAbilityControl.UnregisterAbilityID(38);
  FGameSet.FAbilityControl.UnregisterAbilityID(35);
  FGameSet.FAbilityControl.UnregisterAbilityID(146);
  FGameSet.FAbilityControl.UnregisterAbilityID(147);
  FGameSet.FAbilityControl.UnregisterAbilityID(125);
  FGameSet.FAbilityControl.UnregisterAbilityID(60);
  FGameSet.FAbilityControl.UnregisterAbilityID(117);
  FGameSet.FAbilityControl.UnregisterAbilityID(50);
  FGameSet.FAbilityControl.UnregisterAbilityID(106);
  FGameSet.FAbilityControl.UnregisterAbilityID(107);
  inherited Destroy;
  FDictionary.Free;
  FEmailGames.Free;
  FRegistry.Free;
end;

procedure TAoWEngine.UpdateStartupDirectory;
begin
  if FRegistry.GetStartupDirectory <> '' then SetStartupDirectory(FRegistry.GetStartupDirectory)
  else SetStartupDirectory(ExtractFilePath(Application.ExeName));
  if StartupDirectory[Length(StartupDirectory)] <> '\' then SetStartupDirectory(StartupDirectory + '\');
  BaseImageLibraryPath := StartupDirectory;
  BaseSoundEnginePath := StartupDirectory;
  FDictionary.FFileName := StartupDirectory + 'Dict\' + 'ResStr' + '.mld';
  FDictionary.Open;
end;

class function TAoWEngine.ClassID: Integer;
begin Result := $20001; end;

function TAoWEngine.GetMajorVersion: Integer;
begin Result := (FVersion shr 24) and $FF; end;

function TAoWEngine.GetMinorVersion: Integer;
begin
  Result := (FVersion shr 16) and $FF;
  if Result > 99 then Result := 99;
end;

function TAoWEngine.GetBuildNumber: Integer;
begin
  Result := FVersion and $FFFF;
  if Result > 9999 then Result := 9999;
end;

procedure TAoWEngine.SetVersion(Major, Minor, Build: Integer);
begin
  if Major < 0 then Major := 0;
  if Major > 99 then Major := 99;
  if Minor < 0 then Minor := 0;
  if Minor > 99 then Minor := 99;
  if Build < 0 then Build := 0;
  if Build > 9999 then Build := 9999;
  FVersion := (Major shl 24) + (Minor shl 16) + Build;
end;

function TAoWEngine.GetVersionStr: string;
var Version: Integer;
begin
  Result := IntToStr(GetMajorVersion) + '.';
  Version := GetMinorVersion;
  if Version < 10 then Result := Result + '0' + IntToStr(Version) + '.'
  else Result := Result + IntToStr(Version) + '.';
  Version := GetBuildNumber;
  if Version < 1000 then Result := Result + '0';
  if Version < 100 then Result := Result + '0';
  if Version < 10 then Result := Result + '0';
  Result := Result + IntToStr(Version);
end;

procedure TAoWEngine.CreateHSSet;
begin
  FHSSet := TAoWHSSet.Create(Self);
  FGameSet := TAoWHSSet(FHSSet);
  AoWHSSet := FGameSet;
end;

procedure TAoWEngine.CloseHSM(AProgress: Engine.TProgressEvent);
begin
  try
    inherited CloseHSM(AProgress);
    FGameMap := nil;
    AoWHSMap := nil;
  except
    raise Exception.Create('exception occurred during CloseHSM');
  end;
end;

procedure TAoWEngine.SetHSMap(Value: HSEngine.THSMap);
begin
  inherited SetHSMap(Value);
  if Value is TAoWHSMap then
  begin
    FGameMap := TAoWHSMap(FHSMap);
    AoWHSMap := TAoWHSMap(Value);
  end;
end;

function TAoWEngine.RegisteredVersion: Boolean;
var Registered: Boolean; Mem: TMemoryStream; FileStream: TFileStream; Name: string;
begin
  try
    Mem := TMemoryStream.Create;
    { Original leaks Mem if opening or loading the file raises. }
    FileStream := TFileStream.Create(AoWEngine.StartupDirectory + 'RELEASE\GENERAL.PFS', fmOpenRead or fmShareDenyWrite);
    try
      Mem.LoadFromStream(FileStream);
    finally
      FileStream.Free;
    end;
    try
      Mem.Position := 0;
      Mem.Read(Registered, 1);
      StringFromStream(Name, Mem);
      Result := Registered;
    finally
      Mem.Free;
    end;
  except
    Result := True;
  end;
end;

function TAoWEngine.RegisteredTo: string;
var Registered: Boolean; Mem: TMemoryStream; Name: string;
begin
  try
    Mem := TMemoryStream.Create;
    try
      Mem.LoadFromFile(AoWEngine.StartupDirectory + 'RELEASE\GENERAL.PFS');
      Mem.Read(Registered, 1);
      StringFromStream(Name, Mem);
      Result := Encode(Name, 0);
    finally
      Mem.Free;
    end;
  except
    Result := '';
  end;
end;

function TAoWEngine.RequestAccess(const Name, Code: string): Boolean;
var Registered: string;
  function RegistrationCode(Text: string): string;
  var I, Value: Integer; Hex: string;
  begin
    Result := '';
    if Length(Text) >= 4 then
    begin
      Value := 0;
      for I := 1 to Length(Text) do Inc(Value, Ord(Text[I]));
      for I := 1 to 4 do
      begin
        Hex := IntToHex(Ord(Text[I]) * Value + I, 6);
        Result := Result + Hex[Length(Hex)];
        Inc(Value, Ord(Hex[Length(Hex)]) + Ord(Hex[1]));
      end;
    end;
  end;
begin
  Registered := RegisteredTo;
  if (Registered = Name) and (Name <> '') and (Code = RegistrationCode(Name)) then Result := True
  else Result := False;
end;

procedure TAoWEngine.CloseCampaign;
begin
  if FCampaign <> nil then
  begin
    FCampaign.Free;
    FCampaign := nil;
  end;
end;

procedure TAoWEngine.LoadCampaignMap(AProgress: Engine.TProgressEvent);
begin
  if (FCampaign <> nil) and (FCampaign.FStream <> nil) then
  begin
    CloseHSM(nil);
    AoWEngine.LoadHSMfromStream(FCampaign.FStream, False, AProgress);
  end;
end;

procedure TAoWEngine.LoadCampaign(const FileName: string);
begin
  CloseCampaign;
  FCampaign := TAoWCampaign(RetrieveFromFile(FileName, nil));
  TranslateEObjectFromFile(FCampaign, AoWEngine.StartupDirectory + 'Dict\' + 'Campaign' + '.mld');
  FCampaign.FFileName := FileName;
end;

procedure TAoWEngine.SaveCampaign(const FileName: string);
begin
  if FCampaign <> nil then
  begin
    FCampaign.FStream.Clear;
    if FGameMap <> nil then SaveHSMtoStream(FCampaign.FStream, nil);
    StoreInFile(FileName, FCampaign, nil);
  end;
end;

procedure TAoWEngine.NewCampaign(AClassID: Integer);
begin
  CloseCampaign;
  FCampaign := TAoWCampaign(CreateEObject(AClassID, nil));
end;

procedure TExportTextStream.rwString(var S: string; ID: Integer);
var Buffer: string;
begin
  if not PropertyTable.PropertyExist(ID) then
  begin
    if S <> '' then
    begin
      Buffer := '[' + IntToStr(ID) + ']=' + '|' + S + '|' + #13 + #10;
      FBuffer.Write(Buffer[1], Length(Buffer));
      PropertyTable.Add(ID, 0);
    end;
  end
  else raise EDoublePrioriyID.Create('Double priorityID found');
end;

procedure TExportTextStream.rwStrings(Strings: Classes.TStrings; ID: Integer);
var Buffer, S: string; I: Integer;
begin
  if not PropertyTable.PropertyExist(ID) then
  begin
    if Strings.Count <> 0 then
    begin
      for I := 0 to Strings.Count - 1 do
      begin
        S := S + Strings[I];
        if I <> Strings.Count - 1 then S := S + '<eol>';
      end;
      try
        Buffer := '[' + IntToStr(ID) + ']=';
        if S <> '' then Buffer := Buffer + '|' + S + '|' + #13 + #10
        else Buffer := Buffer + #13 + #10;
        FBuffer.Write(Buffer[1], Length(Buffer));
        PropertyTable.Add(ID, 0);
      finally
      end;
    end;
  end
  else raise EDoublePrioriyID.Create('Double priorityID found');
end;

class function TAoWMapObjectEditor.EditorClassID: Integer;
begin
  Result := $10156;
end;

procedure TAgeOfWondersEngine.SetHSEngine(Value: HSEngine.THSEngine);
begin
  inherited SetHSEngine(Value);
  FGameEngine := Value;
end;

procedure TAgeOfWondersEngine.CreateEngine;
begin
  ValidateAoWEngine;
  if AoWEngine <> nil then SetHSEngine(AoWEngine);
end;

destructor TAgeOfWondersEngine.Destroy;
begin
  FGameEngine := nil;
  Engine := nil;
  inherited Destroy;
end;

