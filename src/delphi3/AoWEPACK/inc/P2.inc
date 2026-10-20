{ P2 recovery in original code order. }
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
      Mode: Boolean; var Info: TP2DamageValue); virtual; abstract;
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

var
  { needs: original shared MovePointTables at 558EA040, initialized by P1.
    This storage is only a stand-in until the shared table is recovered. }
  P2MovePointTables: array[0..255] of TP2MovePointTable;

function P2MoveTypesToInt(MoveTypes: TMoveTypes): Integer; assembler;
asm JMP MoveTypesToInt end;

function P2AbMoves(AOwner: TAbilityOwner): TMoveTypes; assembler;
asm JMP TAbilityOwner.GetAbMoveTypesAll end;

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
  TP2RankAbilityFields = class(TObject)
    Reserved: array[4..55] of Byte;
    Abilities: array[TUnitRank] of Integer;
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
      Inc(Value, Shortint(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers), Player).F_Player_50));
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
    Enchanted := GetAbilityEnabled(P2TypeAbility(List, I).F_Ability_0C);
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
    if (Ability is TUnitEnchantmentAbility) and GetAbilityEnabled(Ability.F_Ability_0C) then
      RemoveAbility(Ability.F_Ability_0C);
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
    if (Ability is TUnitEnchantmentAbility) and GetAbilityEnabled(Ability.F_Ability_0C) then
    begin
      Data := TUnitEnchantmentAbilityData(P2AbilityData(Self, Ability.F_Ability_0C));
      if Shortint(TUnitEnchantment(Data.FEnchantment).F_Enchantment_0C) > -1 then
        TPlayerMagicControl(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),
          Shortint(TUnitEnchantment(Data.FEnchantment).F_Enchantment_0C)).F_Player_54).
          RegisterEnchantment(Integer(Data.FEnchantment));
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
    if (Ability is TUnitEnchantmentAbility) and GetAbilityEnabled(Ability.F_Ability_0C) then
    begin
      Data := TUnitEnchantmentAbilityData(P2AbilityData(Self, Ability.F_Ability_0C));
      if Shortint(TUnitEnchantment(Data.FEnchantment).F_Enchantment_0C) > -1 then
        TPlayerMagicControl(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),
          Shortint(TUnitEnchantment(Data.FEnchantment).F_Enchantment_0C)).F_Player_54).
          UnregisterEnchantment(Integer(Data.FEnchantment));
    end;
  end;
end;

function TAbstractUnit.AbilityToEnchantment(AbilityID: Integer): TUnitEnchantment;
var
  Ability: TAbility;
  Data: TUnitEnchantmentAbilityData;
begin
  Ability := P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl), AbilityID);
  if (Ability is TUnitEnchantmentAbility) and GetAbilityEnabled(Ability.F_Ability_0C) then
  begin
    Data := TUnitEnchantmentAbilityData(P2AbilityData(Self, Ability.F_Ability_0C));
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
    Enchantment := AbilityToEnchantment(P2TypeAbility(List, I).F_Ability_0C);
    if (Enchantment = nil) or (Player = Shortint(Enchantment.F_Enchantment_0C)) then
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
    Enchantment := AbilityToEnchantment(P2TypeAbility(Abilities, I).F_Ability_0C);
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
    if List <> nil then List.DeleteUnit(Integer(Self));
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
  Result := F_CustomAbilityList_0C;
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
  CMP EDX,[EAX].F_CustomAbilityList_0C
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

procedure TAbstractUnit.GetOwnerName(A1: Integer);
begin
  { needs: draft ancestor GetOwnerName is a string result; current A1 is its
    hidden result pointer, proved by EDX at 5577F6A2 and 5577F6C2. }
  P2TranslateRStr(P2InherentRStr, TP2PString(A1)^);
end;

procedure TAbstractUnit.RemoveAbility(A1: Integer);
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

function TAbstractUnit.GetCombatValue(Target: TAbstractUnit; Mode: Boolean): Integer;
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

function TAbstractUnit.GetDescription: Integer;
begin
  Result := 0;
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
  TUnitControl(AoWHSMap.F_AoWHSMap_FC).RegisterUnit(Self);
  if (FGroupID <> 0) and (FPlayer >= 0) then
  begin
    Group := P2FindGroup(TAIGroupList(AoWHSMap.F_AoWHSMap_130), FGroupID);
    if Group <> nil then Group.AddUnit(Integer(Self))
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
  if Group <> nil then Group.DeleteUnit(Integer(Self));
  TUnitControl(AoWHSMap.F_AoWHSMap_FC).UnRegisterUnit(Self);
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
    if Enchantment <> nil then Result := Enchantment.F_Enchantment_10
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

function TAbstractUnit.GetCastingPointsMax: Byte;
begin
  Result := 0;
end;

function TAbstractUnit.GetCastingPoints: Byte;
begin
  Result := 0;
end;

procedure TAbstractUnit.SetCastingPoints(A1: Integer);
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
  if AoWHSMap.F_AoWHSMap_120 <> 0 then Moves := Moves - [mtTunneling];
  Table := P2MovePointTables[P2MoveTypesToInt(Moves)];
  if FPlayer > 0 then
  begin
    if TPlayerMagicControl(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),FPlayer).F_Player_54).F_PlayerMagicControl_44 and 2 <> 0 then
      for Terrain := 0 to 15 do
        if Table[Terrain,4] <> -1 then Table[Terrain,4] := 2;
    if GetAbilityEnabled(23) or GetAbilityEnabled(1) or GetAbilityEnabled(165) then
    begin
      Faster := TPlayerMagicControl(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),FPlayer).F_Player_54).F_PlayerMagicControl_44 and 4 <> 0;
      Slower := TPlayerMagicControl(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),FPlayer).F_Player_54).F_PlayerMagicControl_45 and 4 <> 0;
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
  Result := P2AbMoves(Self);
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
  Cost := P2MovePointTables[P2MoveTypesToInt(GetMoveTypes)][TerrainType,OverlayType];
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
             (P2DiplomaticRelation(TPlayerDiplomaticRelations(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),FPlayer).F_Player_40),Player) = drWar) and
             P2Explored(Field,Player) and
             not P2VisibleForPlayer(AoWHSMap,Walk.X,Walk.Y,MapField.Lhx,Player) then
            Field.SetExplored(Player,0);
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
    begin Ice.F_FrozenWaterHS_0C := 2; Ice.F_FrozenWaterHS_0D := FPlayer; end;
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
    Ice.F_FrozenWaterHS_0C := 2;
    Ice.F_FrozenWaterHS_0D := FPlayer;
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
      begin Ice.F_FrozenWaterHS_0C := 2; Ice.F_FrozenWaterHS_0D := FPlayer; end;
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
  if (AoWHSMap.F_AoWHSMap_138 = 0) or (P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),FPlayer).FPlayerType <> ptHuman) then
  begin
    if Cost > GetMovePoints then SetMovePoints(0)
    else SetMovePoints(GetMovePoints - Cost);
  end;
  if Smallint(NewField.TerrainType) = Ord(ttEarth) then
    AoWHSMap.ChangeTerrain(nil,NewField.Xhx,NewField.Yhx,NewField.Lhx,0,Ord(ttDirt));
  if OldField <> nil then
  begin
    Army := TArmy(Owner);
    if not ((Army is TArmy) and (Army.Transporter(-1) <> nil)) then
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
      DoubleDamage := P2MovePointTables[P2MoveTypesToInt(Moves)][Terrain,Overlay] = 0;
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
  if Group <> nil then Group.DeleteUnit(Integer(Self));
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
    if Shortint(TEnchantment(TUnitEnchantmentAbilityData(P2AbilityData(Self,153)).FEnchantment).F_Enchantment_0C) = -2 then
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
    if Shortint(TEnchantment(TUnitEnchantmentAbilityData(P2AbilityData(Self,167)).FEnchantment).F_Enchantment_0C) = -2 then
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
    if Shortint(TEnchantment(TUnitEnchantmentAbilityData(P2AbilityData(Self,158)).FEnchantment).F_Enchantment_0C) = -2 then
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
    if Integer(TUnitEnchantmentAbilityData(P2AbilityData(Self,53)).FEnchantment) = 1 then
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
      Data.F_DurationAbilityData_10 := 1;
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
    if TPlayerMagicControl(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),Player).F_Player_54).F_PlayerMagicControl_44 and 16 = 0 then
      ResetLifeMasteryBlessing;
    if TPlayerMagicControl(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),FPlayer).F_Player_54).F_PlayerMagicControl_45 and 16 = 0 then
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
      Data.F_DurationAbilityData_10 := 1;
    end;
end;

procedure TAbstractUnit.ValidateDeathMastery;
var
  Player: Shortint;
begin
  Player := FPlayer;
  if Player > 0 then
    if TPlayerMagicControl(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),Player).F_Player_54).F_PlayerMagicControl_45 and 32 = 0 then
      if GetAbilityEnabled(93) then
        if TDurationAbilityData(P2AbilityData(Self,93)).F_DurationAbilityData_10 = 1 then
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
    if TPlayerMagicControl(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),FPlayer).F_Player_54).F_PlayerMagicControl_44 and 64 <> 0 then
      SetFireMasteryProtection;
    if TPlayerMagicControl(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),FPlayer).F_Player_54).F_PlayerMagicControl_44 and 128 <> 0 then
      SetEarthMasteryStoneSkin;
    if TPlayerMagicControl(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),FPlayer).F_Player_54).F_PlayerMagicControl_44 and 16 <> 0 then
      SetLifeMasteryBlessing;
    if TPlayerMagicControl(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),FPlayer).F_Player_54).F_PlayerMagicControl_45 and 16 <> 0 then
      ExecuteLifeMasteryFearRole;
    if TPlayerMagicControl(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),FPlayer).F_Player_54).F_PlayerMagicControl_45 and 32 <> 0 then
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
       (TPlayerMagicControl(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),FPlayer).F_Player_54).F_PlayerMagicControl_45 and 8 <> 0)) then
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
           ((Player <> -1) and (Shortint(ArmyHS.F_ArmyHS_1C.F_Army_12) <> Player)) or
           not TP2AbilityCalls(ArmyHS.F_ArmyHS_1C).CanAddUnit(Self) then Result := False
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
        if Player <> -1 then ArmyHS.F_ArmyHS_1C.SetPlayer(Player);
        if not TP2AbilityCalls(ArmyHS.F_ArmyHS_1C).AddUnit(Self) or not AoWHSMap.PlaceHX(ArmyHS,Walk.X,Walk.Y,L) then
        begin ArmyHS.Free; ArmyHS := nil; end;
        Result := ArmyHS;
      end
      else if TP2AbilityCalls(ArmyHS.F_ArmyHS_1C).AddUnit(Self) then Result := ArmyHS
      else Result := nil;
    end;
    if Result = nil then WalkToNextHN(Walk);
  end;
end;

function TAbstractUnit.CanAddToList: Boolean;
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
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),96).F_Ability_1C).ShowLooped(0,X+32,Y+32,AoWHSMap.Frame,SD)
    else
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),96).F_Ability_1C).Show(0,X+32,Y+32,4,SD);
  if GetAbilityEnabled(98) then
    if Info.Looped then
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),98).F_Ability_1C).ShowLooped(0,X+32,Y+32,AoWHSMap.Frame,SD)
    else
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),98).F_Ability_1C).Show(0,X+32,Y+32,4,SD);
  if GetAbilityEnabled(93) then
    if Info.Looped then
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),93).F_Ability_1C).ShowLooped(0,X+32,Y+32,AoWHSMap.Frame,SD)
    else
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),93).F_Ability_1C).Show(0,X+32,Y+32,4,SD);
  if uoHitPoints in Info.Overlays then
    P2ShowHitPercent(X,Y,SD,P2HitPercent(GetHitPoints,GetHits));
  if uoCombat in Info.Overlays then
  begin
    if GetHitPoints = 0 then
      TCustomImageLibrary(P2AoWHSSet.FCombatImages)[4].Show(X+18,Y+10,SD);
    if GetAbilityEnabled(48) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),48).F_Ability_1C).ShowLooped(0,X+32,Y+40,AoWHSMap.Frame,SD);
    if GetAbilityEnabled(150) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),150).F_Ability_1C).ShowLooped(0,X+32,Y+40,AoWHSMap.Frame,SD);
    if GetAbilityEnabled(149) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),149).F_Ability_1C).ShowLooped(0,X+32,Y+40,AoWHSMap.Frame,SD);
    if GetAbilityEnabled(97) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),97).F_Ability_1C).ShowLooped(0,X+32,Y+40,AoWHSMap.Frame,SD);
    if GetAbilityEnabled(92) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),92).F_Ability_1C).ShowLooped(0,X+32,Y+35,AoWHSMap.Frame,SD);
    if GetAbilityEnabled(95) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),95).F_Ability_1C).ShowLooped(0,X+32,Y+32,AoWHSMap.Frame,SD);
    if GetAbilityEnabled(94) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),94).F_Ability_1C).ShowLooped(0,X+32,Y+35,AoWHSMap.Frame,SD);
    if GetAbilityEnabled(127) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),127).F_Ability_1C).ShowLooped(0,X+32,Y+35,AoWHSMap.Frame,SD);
    if GetAbilityEnabled(107) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),107).F_Ability_1C).ShowLooped(0,X+32,Y+40,AoWHSMap.Frame,SD);
    if GetAbilityEnabled(34) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(P2AoWHSSet.FAbilityControl),34).F_Ability_1C).ShowLooped(0,X+32,Y+40,AoWHSMap.Frame,SD);
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
      if Data <> nil then Data.FEnchantmentPlayerIndex := TP2CombatTurnFields(Combat.F_Combat_0C).Turn;
      RemoveAbility(127);
      Result := Result + [dtCold];
    end;
    if (dtLightning in Active) and TP2OwnerCalls(Self).Expand(92) then
    begin
      Data := TUnitEnchantmentAbilityData(P2AbilityData(Self,92));
      if Data <> nil then TDurationAbilityData(Data).FPlayerIndex := TP2CombatTurnFields(Combat.F_Combat_0C).Turn;
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
              (TIntegerList(P2GetRaceResource(TRaceResourceList(P2AoWHSSet.FRaceResources),I).F_RaceResource_38).
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

function TAbstractUnit.JoinAmount: Integer;
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
    Result := TArmy(Owner).UnitsInTransporter = False;
end;

function TAbstractUnit.Disband: Boolean;
var
  Reason: string;
  Event: TDisbandUnitTE;
begin
  if CanDisband(Reason) and not P2PlayerBusy(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),FPlayer)) then
  begin
    Event := TDisbandUnitTE.Create(nil);
    Event.F_DisbandUnitTE_10 := FUnitID;
    Event.F_DisbandUnitTE_14 := FPlayer;
    TTokenManager(AoWHSMap.F_AoWHSMap_23C).GetTokenControl(FPlayer).AddEvent(Event);
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
    Result := TUnitGFXResourceList(P2AoWHSSet.FUnitGFXResources).GetUnitGFXResource(FUnitResource.F_AbstractUnitResource_18).GetFaceImage;
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
      UpdateDefaultAbilities(TP2RankAbilityFields(FUnitResource).Abilities[Rank]);
  Changed;
end;

function TUnit.GetDescription: Integer;
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
        UpdateDefaultAbilities(TP2RankAbilityFields(FUnitResource).Abilities[Rank]);
      FHitPoints := GetHits;
      FMovePoints := GetMoves;
    end;
  end;
end;

function TUnit.GetUnitGFXResourceIndex: Integer;
begin Result := FUnitResource.F_AbstractUnitResource_18; end;

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
      UpdateDefaultAbilities(TP2RankAbilityFields(FUnitResource).Abilities[Rank]);
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

function TWallUnit.GetHits: Shortint;
begin end;

function TWallUnit.GetName: string;
begin end;

function TWallUnit.GetUnitType: TUnitType;
begin end;

constructor TAdjustableUnit.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TAdjustableUnit.MakeDefaultLevelUnit(A1: Byte);
begin end;

function TAdjustableUnit.GetAttack: Shortint;
begin end;

function TAdjustableUnit.GetDefense: Shortint;
begin end;

function TAdjustableUnit.GetDamage: Shortint;
begin end;

function TAdjustableUnit.GetHits: Shortint;
begin end;

function TAdjustableUnit.GetHitPoints: Shortint;
begin end;

procedure TAdjustableUnit.SetHitPoints(Value: Shortint);
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

function TUnitGFXResource.GetFaceImage: TLibraryImage;
begin end;

function TUnitGFXResource.GetCellImage: ImageLib.TLibraryImage;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TUnitGFXResource.Show(Direction,X,Y: Integer; const SD: TSurfaceDesc);
begin end;

procedure TUnitGFXResource.GetIndex;
begin end;

procedure TUnitGFXResource.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

constructor TUnitGFXResourceList.Create(AOwner: Engine.TECustomNode);
begin end;

function TUnitGFXResourceList.GetUnitGFXResource(Index: Integer): TUnitGFXResource;
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

function TAbstractUnitResource.GetPreviewImage: TLibraryImage;
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

function TUnitResource.GetTransportCapacity: Byte;
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

function TUnitResource.UnitResourceIndex: Integer;
begin end;

class function TUnitResource.ClassID: Integer;
begin Result := 0; end;

function TUnitResource.GetUnitName: string;
begin end;

procedure TUnitResource.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TUnitResource.DropUnit(A1: Integer; A2: Integer; A3: Integer);
begin end;

constructor TUnitResourceList.Create(AOwner: Engine.TECustomNode);
begin end;

function TUnitResourceList.GetUnitResource(Index: Integer): TUnitResource;
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

function THero.GetUnitLevel: Shortint;
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

function THero.ShowEx(X,Y: Integer; const SD: TSurfaceDesc; const Info: TP2UnitShowInfo): Integer;
begin end;

procedure THero.Changed;
begin end;

class function THero.ClassID: Integer;
begin Result := 0; end;

function THero.GetObtainValue: Integer;
begin end;

function THero.GetDescription: Integer;
begin end;

function THero.GetGender: TUnitGender;
begin end;

function THero.GetUnitType: TUnitType;
begin end;

procedure THero.NewDay;
begin end;

procedure THero.UsedSkillPoints;
begin end;

function THero.CanJoin(Player: Shortint): Boolean;
begin end;

procedure THero.EmergedToPlayer;
begin end;

function THero.OfferToJoin(Player: Shortint): Boolean;
begin end;

function THero.GetRace: Shortint;
begin end;

function THero.GetName: string;
begin end;

function THero.GetMoveTypes: TMoveTypes;
begin end;

function THero.GetImmunityTypes: TDamageTypes;
begin end;

function THero.GetProtectionTypes: TDamageTypes;
begin end;

function THero.GetMovePoints: Shortint;
begin end;

procedure THero.SetMovePoints(Value: Shortint);
begin end;

function THero.GetHitPoints: Shortint;
begin end;

procedure THero.SetHitPoints(Value: Shortint);
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

function THero.CanActivate: Boolean;
begin end;

function THero.GetUpkeep: Shortint;
begin end;

procedure THero.SetPlayer(Player: Shortint);
begin end;

procedure THero.CompatibleHero(A1: Integer; A2: Integer);
begin end;

procedure THero.Activate;
begin end;

procedure THero.Deactivate;
begin end;

function THero.GetUnitGFXResourceIndex: Integer;
begin end;

procedure THero.GetSkillPoints;
begin end;

procedure THero.GetSkillPointsMax;
begin end;

procedure THero.GetLevelMax;
begin end;

function THero.GetExperience: Integer;
begin end;

procedure THero.SetExperience(Value: Integer);
begin end;

procedure THero.LevelToExperience(A1: Integer);
begin end;

procedure THero.ExperienceToLevel(A1: Integer);
begin end;

function THero.GetNextLevelExperience: Integer;
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

procedure THero.NewTurn(Player: Shortint);
begin end;

procedure THero.SetAbSet(A1: Integer; A2: Byte);
begin end;

procedure THero.GetAbSet(A1: Integer);
begin end;

procedure THero.GetUnitAbilityEnabled;
begin end;

function THero.GetAbilityCount: Integer;
begin end;

procedure THero.GetSuperlativeEnabledAbOwner(A1: Integer; A2: Integer);
begin end;

procedure THero.GetSuperlativeAbOwner(A1: Integer; A2: Integer);
begin end;

function THero.GetAbilityOwner(AbilityID: Integer): TAbilityOwner;
begin end;

function THero.GetAbilityEnabled(AbilityID: Integer): Boolean;
begin end;

function THero.GetAbilitySet(AbilityID: Integer): Boolean;
begin end;

function THero.GetAbilityName(AbilityID: Integer): string;
begin end;

function THero.GetAbilityLevel(AbilityID: Integer): Integer;
begin end;

function THero.GetInherentAttack: Shortint;
begin end;

function THero.GetAttack: Shortint;
begin end;

function THero.GetInherentDefense: Shortint;
begin end;

function THero.GetDefense: Shortint;
begin end;

function THero.GetInherentDamage: Shortint;
begin end;

function THero.GetDamage: Shortint;
begin end;

function THero.GetInherentResistance: Shortint;
begin end;

function THero.GetResistance: Shortint;
begin end;

function THero.GetHits: Shortint;
begin end;

function THero.GetMoves: Shortint;
begin end;

function THero.GetPowerGeneration: Integer;
begin end;

function THero.GetCastingPointsMax: Byte;
begin end;

function THero.GetCastingPoints: Byte;
begin end;

procedure THero.SetCastingPoints(A1: Integer);
begin end;

function THero.GetPreviewImage: TLibraryImage;
begin end;

procedure THero.ResetSkillPoints;
begin end;

procedure THero.ResetResourceSettings;
begin end;

procedure THero.UpdateSettings;
begin end;

procedure THero.SetRace(A1: Byte; A2: Integer);
begin end;

function THero.GetFace: TLibraryImage;
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

function TLeader.GetPowerGeneration: Integer;
begin end;

procedure TLeader.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TLeader.GetEngine: Engine.TEngine;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TLeader.SetHeroResourceIndex(A1: Integer);
begin end;

procedure TLeader.SetPlayer(Player: Shortint);
begin end;

procedure TLeader.Killed;
begin end;

function TLeader.CanActivate: Boolean;
begin end;

procedure TLeader.Activate;
begin end;

procedure TLeader.Deactivate;
begin end;

procedure TLeader.EditDropMsg(A1: Integer);
begin end;

function TLeader.CanDisband(var Reason: string): Boolean;
begin end;

function TLeader.GetUpkeep: Shortint;
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

procedure TArmy.SetPlayer(Player: Shortint);
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

function TArmy.Transporter(Player: Shortint): TAbstractUnit;
begin end;

procedure TArmy.IndexOfTransporter(A1: Integer);
begin end;

function TArmy.UnitsInTransporter: Boolean;
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

