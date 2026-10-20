{ Anonymous arithmetic helper at 55726100. }
function P4OffensiveStrength(Attack, Damage, Repeats: Integer): Integer;
begin
  if Damage > 10 then Damage := 10;
  Result := Attack * Damage * Repeats div 2;
end;

{ Engine's private list accessor is reached through its public property. }
function P4LevelCost(Costs: TIntegerList; Level: Integer): Integer;
begin
  Result := Costs[Level];
end;

{ P4 abilities and magic.
  Adjustable, duration, multilevel, unit-enchantment, cosmetic-surgery, leadership,
  strike, touch, invoke-death, healing and dispel-magic abilities and their combat
  actions are recovered; healing token events and selectors are recovered.
  Dispel-magic token events/selectors, spellcasting, ranged/bolt/breath/flame
  attacks and command ability data/commanded abilities are recovered.
  Command, dominate, charm, seduce, construction controls, spell-cast event logs,
  unit-spell combat actions and unit-spell token events are recovered.
  Draft recovery next resumes at TUnitSpell (5577AC34).
  The base spell, spell events/control/list/casters and power sources are recovered.
  Compatibility declarations preserve calls to other packages' draft APIs; these
  adapters never create instances of their declaration-only views. }

type
  P4LongString = ^string;
  P4ShortInt = ^ShortInt;
  TUnitControlCallViewP4 = class(TUnitControl)
    function FindUnitResult(ID: Integer): TAbstractUnit;
  end;
  { P1's unmarked $FC field is still Integer. This local view changes no layout. }
  TP4MapUnitControl = record
    Reserved: array[0..$FB] of Byte;
    UnitControl: TUnitControlCallViewP4;
  end;
  PP4MapUnitControl = ^TP4MapUnitControl;
  TSpellTECallViewP4 = class(TTokenEvent)
    function ValidateValue(Source: TAbstractUnit): Boolean; virtual; abstract;
    function ProcessValue(Source: TAbstractUnit; Pass: Integer): Boolean; virtual; abstract;
  end;
  TP4TokenExecuterState = record
    Reserved: array[0..$1F] of Byte;
    ExecuteCount: Integer;
  end;
  PP4TokenExecuterState = ^TP4TokenExecuterState;
  THeroCastingViewP4 = class(THero)
    function SpellMana(Spell: TSpell): Integer;
  end;
  TP4DamageValue = record
    V0, V1, V2, V3: Integer;
    DamageTypes: TDamageTypes;
  end;
  PP4DamageValue = ^TP4DamageValue;
  TP4CombatInfo = record
    V0, V1: Byte;
    DamageTypes: TDamageTypes;
    V4, V5, V6: Byte;
    Modes: TCombatModes;
  end;
  PP4CombatInfo = ^TP4CombatInfo;
  { Temporary declaration views: no instances are created. }
  TDurationReturnView = class(TAbility)
    function GetDuration(AbilityOwner: TAbilityOwner): Byte; virtual; abstract;
    function GetTotalDuration: Integer; virtual; abstract;
  end;
  { needs: P3 TCombatObject.GetAbilityOwner: TAbilityOwner at VMT $B8.
    This declaration-only view preserves TEObject's slots through $48 and
    the TCombatObject slots $4C..$B8; no instances are created. }
  { Only VMT $128/$12C are called; this view is never instantiated. }
  TCastingPointsReturnViewP4 = class(TDurationReturnView)
    procedure Slot114; virtual; abstract;
    procedure Slot118; virtual; abstract;
    procedure Slot11C; virtual; abstract;
    procedure Slot120; virtual; abstract;
    procedure Slot124; virtual; abstract;
    function CastingPointsMax: ShortInt; virtual; abstract;
    function CastingPoints: ShortInt; virtual; abstract;
  end;

const
  { CommandAbilityIDs is declared in the interface (557F8492). }
  P4LeadershipAttack: array[0..4] of Shortint = (0, 1, 1, 2, 2);
  P4LeadershipDefense: array[0..4] of Shortint = (2, 0, 1, 1, 2);
  { Class-reference constants used by the recovered multilevel implementation. }
  P4CommandDataClass: TEObjectClass = TCommandAbilityData;
  P4CommandedDataClass: TEObjectClass = TCommandedAbilityData;
  P4PossessedDataClass: TEObjectClass = TPossessedAbilityData;
  P4DispelMagicDataClass: TEObjectClass = TDispelMagicAbilityData;
  P4HealingDataClass: TEObjectClass = THealingAbilityData;
  P4DurationDataClass: TEObjectClass = TDurationAbilityData;
  P4MultiLevelDataClass: TEObjectClass = TMultiLevelAbilityData;
  P4EmptySelection: Word = 0;
  P4EmptyDamageTypes: TDamageTypes = [];
  P4EmptyCombatModes: TCombatModes = [];
  P4CastSpellActionClass: TEObjectClass = TAICastSpellAction;
  P4CombatCasterClass: TEObjectClass = TCombatSpellCaster;
  P4ImageAnimationClass: TEObjectClass = TImageSequenceAnimation;
  P4UnitSelectionClass: TEObjectClass = TUnitUserList;

resourcestring
  P4CastXRStr = 'Cast %s';
  P4XCastingReadyRStr = '%s ready';
  P4RebuildXRStr = 'Rebuild %s';
  P4StructureRStr = 'Structure';
  P4NoRazedStructuresRStr = 'No razed structure found';
  P4BuildRoadRStr = 'Build Roads';
  P4CannotBuildUndergroundRStr = 'Cannot build %s underground';
  P4RoadsRStr = 'Roads';
  P4NotEnoughGoldRStr = 'Not enough gold.';
  P4ConstructRStr = 'Construct';
  P4AbilitiesRStr = 'Abilities';
  DominatedRStr = 'Dominated';
  DominateRStr = 'Dominate';
  CharmedRStr = 'Charmed';
  CharmRStr = 'Charm';
  SeducedRStr = 'Seduced';
  SeduceRStr = 'Seduce';
  PossessedRStr = 'Possessed';
  PossessRStr = 'Possess';
  WebRStr = 'Web';
  InvokeDeathRStr = 'Invoke Death';
  HealingRStr = 'Healing';
  DispelMagicRStr = 'Dispel Magic';
  DispelMagicFailedRStr = 'Dispel Magic failed';
  XSpellsSuccessfullyDispelledRStr = '%s spell(s) dispelled';
  SpellCastingRStr = 'Spell Casting';
  FlameThrowingRStr = 'Flame Throwing';
  UsedRStr = 'Used';
  SelectUnitForXRStr = 'Select unit for %s';
  { EntangleRStr is declared in the interface (557F8A68). }
  { TurnUndeadRStr is declared in the interface (557F7B94). }
  StrikeRStr = 'Strike';
  WallCrushingRStr = 'Wall Crushing';
  SelfDestructRStr = 'Self Destruct';
  RoundAttackRStr = 'Round Attack';
  LeadershipRStr = 'Leadership';
  NotEnoughCastingPointsRStr = 'Not enough channeling points';
  P4SpellWardBlocksCastRStr = 'Spell Ward locks all global enchantments';
  P4ExternalPowerRStr = 'External';
  CosmeticSurgeryRStr = 'Cosmagic Surgery';
  P4TransportUnitsRStr = 'Transport (%s units)';
  XIsOutOfSightRStr = '%s is out of sight';
  P4ManaRStr = 'Mana';
  DurationDaysRStr = '(%s/%s days)';
  DurationCombatTurnRStr = '(%s/%s turns)';
  DurationEntireCombatRStr = '(combat only)';

procedure P4TranslateInto(const S: string; var Dest: string); assembler;
{ needs: P1 TranslateRStr has a string result at EDX; 5577C2D4. }
asm
  JMP TranslateRStr
end;

function P4MapRandom(Map: TAoWHSMap; Range: Integer): Integer; assembler;
{ needs: P1 TAoWHSMap.Random returns Integer; used at 55779F7A. }
asm
  JMP TAoWHSMap.Random
end;

function P4GetPlayer(Players: TPlayerList; PlayerIndex: Integer): TPlayer; assembler;
{ needs: P1 TPlayerList.GetPlayers returns TPlayer; EAX is consumed at 55779710. }
asm
  JMP TPlayerList.GetPlayers
end;

function P4RequestUpkeep(Magic: TPlayerMagicControl; Priority: Integer): Integer; assembler;
{ needs: AIRequestOverrideUpkeep has one explicit argument and returns Integer. }
asm
  JMP TPlayerMagicControl.AIRequestOverrideUpkeep
end;

function P4RequestBudget(Manager: TAIBudgetManager; A1, A2, A3, A4, A5, A6: Integer): Boolean; assembler;
{ needs: P5 RequestBudgetExpenseEx returns Boolean; 55779781 tests AL. }
asm
  POP EBP
  JMP TAIBudgetManager.RequestBudgetExpenseEx
end;

function P4BudgetMade(Manager: TAIBudgetManager; A1, A2, A3, A4, A5, A6: Integer): Boolean; assembler;
{ needs: P5 BudgetExpenseMadeEx returns Boolean; 5577980F leaves AL for return. }
asm
  POP EBP
  JMP TAIBudgetManager.BudgetExpenseMadeEx
end;

function THeroCastingViewP4.SpellMana(Spell: TSpell): Integer; assembler;
{ needs: P2 THero.CastingMana(Spell: TSpell): Integer; 55779557 returns EAX. }
asm
  JMP THero.CastingMana
end;

{ These adapters retain byte coordinates while the P1 interface has Integer drafts. }
function TUnitControlCallViewP4.FindUnitResult(ID: Integer): TAbstractUnit; assembler;
{ needs: P2 TUnitControl.FindUnit returns TAbstractUnit; 55779966. }
asm
  JMP TUnitControl.FindUnit
end;

function TAdjustableAbility.GetAbilityType: TAbilityType;
begin
  Result := FAbilityType;
end;

class function TDurationAbilityData.ClassID: Integer;
begin
  Result := $22002;
end;

function TDurationAbilityData.GetAbilityID: Integer;
begin
  Result := FAbilityID;
end;

procedure TDurationAbilityData.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(FDuration, 11);
  Stream.rwWord(FAbilityID, 12);
  Stream.rwByte(FPlayerIndex, 13);
  Stream.rwInteger(FSource, 14);
end;

constructor TDurationAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
end;

function TDurationAbility.AbilityDataClass: TEObjectClass;
begin
  Result := TDurationAbilityData;
end;

function TDurationAbility.GetTotalDuration: Integer;
begin
  Result := 3;
end;

procedure TDurationAbility.NewDay(A1: TAbilityOwner);
begin
  if AoWHSMap.FDay = 1 then
    TAbilityOwner(A1).RemoveAbility(FAbilityID);
end;

procedure TDurationAbility.NewTurn(A1: TAbilityOwner; A2: Shortint);
var
  Data: TDurationAbilityData;
begin
  if FDurationMode = dmDay then
  begin
    Data := TDurationAbilityData(A1.GetAbilityData(FAbilityID));
    if Data <> nil then
    begin
      if (Data.FDuration <> 0) and (Data.FPlayerIndex = A2) then
      begin
        Dec(Data.FDuration);
        if Data.FDuration = 0 then
          A1.RemoveAbility(FAbilityID);
      end;
    end
    else
      A1.RemoveAbility(FAbilityID);
  end;
end;

procedure TDurationAbility.NewCombatTurn(A1: TCombatObject; A2: Shortint);
var
  Data: TDurationAbilityData;
begin
  if FDurationMode = dmCombatTurn then
  begin
    Data := TDurationAbilityData(A1.GetAbilityOwner.GetAbilityData(FAbilityID));
    if Data <> nil then
    begin
      if (Data.FDuration <> 0) and (Data.FPlayerIndex = A2) then
      begin
        Dec(Data.FDuration);
        if Data.FDuration = 0 then
          A1.GetAbilityOwner.RemoveAbility(FAbilityID);
      end;
    end
    else
      A1.GetAbilityOwner.RemoveAbility(FAbilityID);
  end;
end;

procedure TDurationAbility.CombatDone(A1: TCombatObject);
begin
  case FDurationMode of
    dmCombatTurn, dmEntireCombat:
      A1.GetAbilityOwner.RemoveAbility(FAbilityID);
  end;
end;

function TDurationAbility.GetName(A1: TAbilityOwner): string;
begin
  if A1 <> nil then
    case FDurationMode of
      dmDay:
        begin
          Result := inherited GetName(A1);
          if GetDuration(A1) <> 0 then
            Result := Result + ' ' +
              Format(TranslateRStr(DurationDaysRStr),
                [IntToStr(GetDuration(A1)), IntToStr(GetTotalDuration)]);
        end;
      dmCombatTurn:
        Result := inherited GetName(A1) + ' ' +
          Format(TranslateRStr(DurationCombatTurnRStr),
            [IntToStr(GetDuration(A1)), IntToStr(GetTotalDuration)]);
      dmEntireCombat:
        Result := inherited GetName(A1) + ' ' + TranslateRStr(DurationEntireCombatRStr);
      { Original leaves the string untouched for dmNone and a nonnil owner. }
    end
  else
    Result := inherited GetName(A1);
end;

function TDurationAbility.GetDuration(AbilityOwner: TAbilityOwner): Byte;
var
  Data: TDurationAbilityData;
begin
  Data := TDurationAbilityData(AbilityOwner.GetAbilityData(FAbilityID));
  if Data <> nil then
    Result := Data.FDuration
  else
    Result := 0;
end;

function TDurationAbility.Expand(A1: TAbilityOwner): Boolean;
{ needs: P1 TAbility.Expand(AbilityOwner: TAbilityOwner): Boolean.
  A2 is a spurious draft parameter; original 55765054 does not consume ECX. }
asm
  PUSH EBX
  PUSH ESI
  PUSH EDI
  PUSH EBP
  MOV EDI, EDX
  MOV EBP, EAX
  XOR EBX, EBX
  MOV EDX, [EBP].TAbility.FAbilityID
  MOV EAX, EDI
  CALL TAbilityOwner.GetAbilityData
  MOV ESI, EAX
  TEST ESI, ESI
  JNE @@Existing
  XOR ECX, ECX
  MOV DL, 1
  MOV EAX, DWORD PTR [P4DurationDataClass]
  CALL TEObject.Create
  MOV ESI, EAX
  MOV AX, WORD PTR [EBP].TAbility.FAbilityID
  MOV [ESI].TDurationAbilityData.FAbilityID, AX
  MOV EAX, EBP
  MOV EDX, [EAX]
  CALL DWORD PTR [EDX + $110]
  MOV [ESI].TDurationAbilityData.FDuration, AL
  PUSH 1
  MOV ECX, [EBP].TAbility.FAbilityID
  MOV EDX, EDI
  MOV EAX, EBP
  CALL TAbility.SetAb
  MOV EDX, ESI
  MOV EAX, EDI
  CALL TAbilityOwner.AddAbilityData
  MOV BL, 1
  JMP @@Done
@@Existing:
  MOV EAX, EBP
  MOV EDX, [EAX]
  CALL DWORD PTR [EDX + $110]
  XOR EDX, EDX
  MOV DL, [ESI].TDurationAbilityData.FDuration
  CMP EAX, EDX
  JLE @@Done
  MOV BL, 1
  MOV EAX, EBP
  MOV EDX, [EAX]
  CALL DWORD PTR [EDX + $110]
  MOV [ESI].TDurationAbilityData.FDuration, AL
@@Done:
  MOV EAX, EBX
  POP EBP
  POP EDI
  POP ESI
  POP EBX
end;

function TDurationAbility.Remove(A1: TAbilityOwner): Boolean;
{ needs: P1 TAbility.Remove(AbilityOwner: TAbilityOwner): Boolean.
  Original 557650D8 returns success in AL; A2 is unused. }
asm
  PUSH EBX
  PUSH ESI
  PUSH EDI
  PUSH EBP
  MOV ESI, EDX
  MOV EBP, EAX
  MOV BL, 1
  MOV EDX, [EBP].TAbility.FAbilityID
  MOV EAX, ESI
  CALL TAbilityOwner.GetAbilityData
  MOV EDI, EAX
  TEST EDI, EDI
  JE @@Missing
  PUSH 0
  MOV ECX, [EBP].TAbility.FAbilityID
  MOV EDX, ESI
  MOV EAX, EBP
  CALL TAbility.SetAb
  MOV EDX, EDI
  MOV EAX, ESI
  CALL TAbilityOwner.RemoveAbilityData
  JMP @@Done
@@Missing:
  PUSH 0
  MOV ECX, [EBP].TAbility.FAbilityID
  MOV EDX, ESI
  MOV EAX, EBP
  CALL TAbility.SetAb
  XOR EBX, EBX
@@Done:
  MOV EAX, EBX
  POP EBP
  POP EDI
  POP ESI
  POP EBX
end;

procedure TMultiLevelAbilityData.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(FLevel, 10);
  Stream.rwWord(FLevelAbilityID, 11);
end;

class function TMultiLevelAbilityData.ClassID: Integer;
begin
  Result := $22001;
end;

function TMultiLevelAbilityData.GetAbilityID: Integer;
begin
  Result := FLevelAbilityID;
end;

constructor TMultiLevelAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FLevelCosts := TIntegerList.Create;
  FMaxLevel := 4;
end;

destructor TMultiLevelAbility.Destroy;
begin
  FLevelCosts.Free;
  inherited Destroy;
end;

function TMultiLevelAbility.GetLevel(A1: TAbilityOwner): Integer;
{ needs: P1 inherited declaration returns Integer for TAbilityOwner in EDX. }
asm
  PUSH EBX
  PUSH ESI
  MOV ESI, EDX
  MOV EBX, EAX
  TEST ESI, ESI
  JE @@NoOwner
  MOV EDX, [EBX].TAbility.FAbilityID
  MOV EAX, ESI
  CALL TAbilityOwner.GetAbilityData
  TEST EAX, EAX
  JE @@Missing
  MOVZX EAX, [EAX].TMultiLevelAbilityData.FLevel
  DB $EB, $07 { branch past the missing-data exit and nil-owner zero result }
@@Missing:
  XOR EAX, EAX
  POP ESI
  POP EBX
  RET
@@NoOwner:
  XOR EAX, EAX
@@Done:
  POP ESI
  POP EBX
end;

procedure TMultiLevelAbility.GetInherentLevel(A1: Integer);
{ needs: P1 inherited declaration returns Integer for TAbilityOwner in EDX. }
asm
  PUSH EBX
  PUSH ESI
  MOV ESI, EDX
  MOV EBX, EAX
  TEST ESI, ESI
  JE @@NoOwner
  MOV EDX, [EBX].TAbility.FAbilityID
  MOV EAX, ESI
  CALL TAbilityOwner.GetAbilityData
  TEST EAX, EAX
  JE @@Missing
  MOVZX EAX, [EAX].TMultiLevelAbilityData.FLevel
  DB $EB, $07 { branch past the missing-data exit and nil-owner zero result }
@@Missing:
  XOR EAX, EAX
  POP ESI
  POP EBX
  RET
@@NoOwner:
  XOR EAX, EAX
@@Done:
  POP ESI
  POP EBX
end;

function TMultiLevelAbility.AbilityDataClass: TEObjectClass;
asm
  MOV EAX, DWORD PTR [P4MultiLevelDataClass]
end;

function TMultiLevelAbility.GetLevelName(A1: Integer): string;
begin
  Result := 'Unknown ' + IntToStr(A1);
end;

function TMultiLevelAbility.GetName(A1: TAbilityOwner): string;
asm
  PUSH EBX
  PUSH ESI
  PUSH EDI
  MOV EDI, ECX
  MOV ESI, EDX
  MOV EBX, EAX
  MOV EDX, ESI
  MOV EAX, EBX
  MOV ECX, [EAX]
  CALL DWORD PTR [ECX + $70]
  MOV EDX, EAX
  MOV ECX, EDI
  MOV EAX, EBX
  MOV EBX, [EAX]
  CALL DWORD PTR [EBX + $10C]
  POP EDI
  POP ESI
  POP EBX
end;

function TMultiLevelAbility.ExpandName(A1: TAbilityOwner): string;
asm
  PUSH EBX
  PUSH ESI
  PUSH EDI
  MOV EDI, ECX
  MOV ESI, EDX
  MOV EBX, EAX
  MOV EDX, ESI
  MOV EAX, EBX
  MOV ECX, [EAX]
  CALL DWORD PTR [ECX + $70]
  MOV EDX, EAX
  INC EDX
  MOV ECX, EDI
  MOV EAX, EBX
  MOV EBX, [EAX]
  CALL DWORD PTR [EBX + $10C]
  POP EDI
  POP ESI
  POP EBX
end;

function TMultiLevelAbility.ExpandCost(A1: TAbilityOwner): Integer;
{ needs: P1 TAbility.ExpandCost(AbilityOwner: TAbilityOwner): Integer; EDX is forwarded at 557652E4. }
asm
  PUSH EBX
  MOV EBX, EAX
  MOV EAX, EBX
  MOV ECX, [EAX]
  CALL DWORD PTR [ECX + $94]
  CMP EAX, [EBX].TMultiLevelAbility.FMaxLevel
  JGE @@Max
  LEA EDX, [EAX + 1]
  MOV EAX, [EBX].TMultiLevelAbility.FLevelCosts
  CALL P4LevelCost
  POP EBX
  RET
@@Max:
  XOR EAX, EAX
  POP EBX
end;

function TMultiLevelAbility.CanExpand(A1: TAbilityOwner): Boolean;
{ needs: P1 selection-types and inherent-level virtuals have results; 55765312/5576532E. }
asm
  PUSH EBX
  PUSH ESI
  MOV ESI, EDX
  MOV EBX, EAX
  MOV EAX, ESI
  MOV EDX, [EAX]
  CALL DWORD PTR [EDX + $8C]
  AND AX, [EBX].TAbility.FSelectionTypes
  MOV DX, [P4EmptySelection]
  CMP DX, AX
  JE @@No
  MOV EDX, ESI
  MOV EAX, EBX
  MOV ECX, [EAX]
  CALL DWORD PTR [ECX + $94]
  CMP EAX, [EBX].TMultiLevelAbility.FMaxLevel
  JL @@Yes
@@No:
  XOR EAX, EAX
  POP ESI
  POP EBX
  RET
@@Yes:
  MOV AL, 1
  POP ESI
  POP EBX
end;

function TMultiLevelAbility.GetSkillPoints(A1: TAbilityOwner): Integer;
{ Original bug: charges the current level's cost repeatedly, rather than each preceding level's cost. }
asm
  PUSH EBX
  PUSH ESI
  PUSH EDI
  PUSH EBP
  MOV ESI, EAX
  MOV EAX, ESI
  MOV ECX, [EAX]
  CALL DWORD PTR [ECX + $94]
  MOV EDI, EAX
  XOR EBP, EBP
  MOV EBX, EDI
  TEST EBX, EBX
  JLE @@Done
@@Next:
  MOV EDX, EDI
  MOV EAX, [ESI].TMultiLevelAbility.FLevelCosts
  CALL P4LevelCost
  ADD EBP, EAX
  DEC EBX
  JNE @@Next
@@Done:
  MOV EAX, EBP
  POP EBP
  POP EDI
  POP ESI
  POP EBX
end;

function TMultiLevelAbility.Expand(A1: TAbilityOwner): Boolean;
{ needs: P1 TAbility.Expand returns Boolean and takes one ability owner. }
asm
  PUSH EBX
  PUSH ESI
  PUSH EDI
  PUSH EBP
  MOV EDI, EDX
  MOV ESI, EAX
  XOR EBX, EBX
  MOV EDX, [ESI].TAbility.FAbilityID
  MOV EAX, EDI
  CALL TAbilityOwner.GetAbilityData
  MOV EBP, EAX
  TEST EBP, EBP
  JNE @@Existing
  MOV EAX, [ESI]
  CALL DWORD PTR [EAX + $108]
  XOR ECX, ECX
  MOV DL, 1
  CALL DWORD PTR [EAX + $20]
  MOV EBP, EAX
  MOV AX, WORD PTR [ESI].TAbility.FAbilityID
  MOV [EBP].TMultiLevelAbilityData.FLevelAbilityID, AX
  MOV [EBP].TMultiLevelAbilityData.FLevel, 1
  PUSH 1
  MOV ECX, [ESI].TAbility.FAbilityID
  MOV EDX, EDI
  MOV EAX, ESI
  CALL TAbility.SetAb
  MOV EDX, EBP
  MOV EAX, EDI
  CALL TAbilityOwner.AddAbilityData
  MOV BL, 1
  JMP @@Done
@@Existing:
  XOR EAX, EAX
  MOV AL, [EBP].TMultiLevelAbilityData.FLevel
  CMP EAX, [ESI].TMultiLevelAbility.FMaxLevel
  JE @@Done
  MOV BL, 1
  INC [EBP].TMultiLevelAbilityData.FLevel
@@Done:
  MOV EAX, EBX
  POP EBP
  POP EDI
  POP ESI
  POP EBX
end;

function TMultiLevelAbility.Remove(A1: TAbilityOwner): Boolean;
{ needs: P1 TAbility.Remove returns Boolean and takes one ability owner. }
asm
  PUSH EBX
  PUSH ESI
  PUSH EDI
  PUSH EBP
  MOV EDI, EDX
  MOV EBP, EAX
  MOV BL, 1
  MOV EDX, [EBP].TAbility.FAbilityID
  MOV EAX, EDI
  CALL TAbilityOwner.GetAbilityData
  MOV ESI, EAX
  TEST ESI, ESI
  JE @@Missing
  CMP [ESI].TMultiLevelAbilityData.FLevel, 1
  JNE @@Decrement
  PUSH 0
  MOV ECX, [EBP].TAbility.FAbilityID
  MOV EDX, EDI
  MOV EAX, EBP
  CALL TAbility.SetAb
  MOV EDX, ESI
  MOV EAX, EDI
  CALL TAbilityOwner.RemoveAbilityData
  JMP @@Done
@@Decrement:
  DEC [ESI].TMultiLevelAbilityData.FLevel
  JMP @@Done
@@Missing:
  PUSH 0
  MOV ECX, [EBP].TAbility.FAbilityID
  MOV EDX, EDI
  MOV EAX, EBP
  CALL TAbility.SetAb
  XOR EBX, EBX
@@Done:
  MOV EAX, EBX
  POP EBP
  POP EDI
  POP ESI
  POP EBX
end;

constructor TUnitEnchantmentAbilityData.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FEnchantmentPlayerIndex := -1;
  FEnchantmentDuration := -1;
end;

class function TUnitEnchantmentAbilityData.ClassID: Integer;
begin
  Result := $202AC;
end;

destructor TUnitEnchantmentAbilityData.Destroy;
var
  Enchantment: TUnitEnchantment;
begin
  Enchantment := FEnchantment;
  if Enchantment <> nil then
    Enchantment.Free;
  inherited Destroy;
end;

function TUnitEnchantmentAbilityData.GetAbilityID: Integer;
begin
  Result := FEnchantmentAbilityID;
end;

procedure TUnitEnchantmentAbilityData.SetEnchantment(Enchantment: TUnitEnchantment);
var
  OldEnchantment: TUnitEnchantment;
begin
  OldEnchantment := FEnchantment;
  if OldEnchantment <> nil then
    OldEnchantment.Free;
  FEnchantment := Enchantment;
end;

procedure TUnitEnchantmentAbilityData.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwWord(FEnchantmentAbilityID, 15);
  Stream.rwCreateEObject(TEObject(FEnchantment), nil, 16);
  Stream.rwShortintEx(FEnchantmentPlayerIndex, -1, 17);
  Stream.rwShortintEx(FEnchantmentDuration, -1, 18);
end;

constructor TUnitEnchantmentAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityType := atEnchantment;
  FSelectionTypes := [];
end;

function TUnitEnchantmentAbility.GetAIUpkeepPriority(A1: TAbilityOwner): Integer;
begin
  Result := 0;
end;

function TUnitEnchantmentAbility.GetName(A1: TAbilityOwner): string;
begin
  if A1 <> nil then
    case GetDurationMode of
      dmDay:
        begin
          Result := inherited GetName(A1);
          if GetDuration(A1) <> 0 then
            Result := Result + ' ' +
              Format(TranslateRStr(DurationDaysRStr),
                [IntToStr(GetDuration(A1)), IntToStr(GetTotalDuration)]);
        end;
      dmCombatTurn:
        Result := inherited GetName(A1) + ' ' +
          Format(TranslateRStr(DurationCombatTurnRStr),
            [IntToStr(GetDuration(A1)), IntToStr(GetTotalDuration)]);
      dmEntireCombat:
        Result := inherited GetName(A1) + ' ' + TranslateRStr(DurationEntireCombatRStr);
      else Result := inherited GetName(A1);
    end
  else
    Result := inherited GetName(A1);
end;

function TUnitEnchantmentAbility.GetSourceName(A1: TAbilityOwner): string;
var
  Data: TUnitEnchantmentAbilityData;
  Source: TAbstractUnit;
begin
  if AoWHSMap <> nil then
  begin
    Data := TUnitEnchantmentAbilityData(A1.GetAbilityData(FAbilityID));
    Source := AoWHSMap.FUnitControl.FindUnit(Data.FEnchantment.FUnitID);
    { Original also reports player zero as unknown. }
    if Data.FEnchantment.FSource <= 0 then
      Result := TranslateRStr(UnknownRStr)
    else if (Source <> nil) and (Source.FPlayer = Data.FEnchantment.FSource) then
      Result := TranslateRStr(P4ManaRStr)
    else
      Result := AoWHSMap.FPlayers.GetPlayers(Data.FEnchantment.FSource).FLeader.FHeroName;
  end
  else
    Result := TranslateRStr(UnknownRStr);
end;

function TUnitEnchantmentAbility.AbilityDataClass: TEObjectClass;
begin
  Result := TUnitEnchantmentAbilityData;
end;

function TUnitEnchantmentAbility.CreateEnchantment: TUnitEnchantment;
begin
  Result := TUnitEnchantment.Create(nil);
end;

function TUnitEnchantmentAbility.Expand(A1: TAbilityOwner): Boolean;
var
  Data: TUnitEnchantmentAbilityData;
  Enchantment: TUnitEnchantment;
begin
  Assert(A1 is TAbstractUnit);
  Result := False;
  Data := TUnitEnchantmentAbilityData(A1.GetAbilityData(FAbilityID));
  if Data = nil then
  begin
    Assert(TAbstractUnit(A1).FUnitID > 0);
    Data := TUnitEnchantmentAbilityData.Create(nil);
    Data.FEnchantmentAbilityID := FAbilityID;
    Data.FEnchantmentDuration := GetTotalDuration;
    Enchantment := CreateEnchantment;
    Data.FEnchantment := Enchantment;
    Enchantment.FEnchantmentAbilityID := FAbilityID;
    Enchantment.FUnitID := TAbstractUnit(A1).FUnitID;
    SetAb(A1, FAbilityID, 1);
    A1.AddAbilityData(Data);
    Result := True;
  end
  else
    Data.FEnchantmentDuration := GetTotalDuration;
end;

function TUnitEnchantmentAbility.Remove(A1: TAbilityOwner): Boolean;
var
  Data: TUnitEnchantmentAbilityData;
begin
  Result := True;
  Data := TUnitEnchantmentAbilityData(A1.GetAbilityData(FAbilityID));
  if Data <> nil then
  begin
    if (AoWHSMap <> nil) and (Data.FEnchantment.FSource > -1) then
      AoWHSMap.FPlayers.GetPlayers(Data.FEnchantment.FSource).FMagicControl.UnregisterEnchantment(Data.FEnchantment);
    SetAb(A1, FAbilityID, 0);
    A1.RemoveAbilityData(Data);
  end
  else
  begin
    SetAb(A1, FAbilityID, 0);
    Result := False;
  end;
end;

function TUnitEnchantmentAbility.GetDurationMode: TDurationMode;
begin
  Result := dmNone;
end;

function TUnitEnchantmentAbility.GetDuration(A1: TAbilityOwner): Byte;
var
  Data: TUnitEnchantmentAbilityData;
begin
  Data := TUnitEnchantmentAbilityData(A1.GetAbilityData(FAbilityID));
  if Data <> nil then
    Result := Data.FEnchantmentDuration
  else
    Result := 0;
end;

function TUnitEnchantmentAbility.GetTotalDuration: Shortint;
begin
  Result := -1;
end;

procedure TUnitEnchantmentAbility.NewTurn(A1: TAbilityOwner; A2: Shortint);
var
  Data: TUnitEnchantmentAbilityData;
begin
  if GetDurationMode = dmDay then
  begin
    Data := TUnitEnchantmentAbilityData(A1.GetAbilityData(FAbilityID));
    if Data <> nil then
    begin
      if (Data.FEnchantmentDuration > 0) and (A2 = Data.FEnchantmentPlayerIndex) then
      begin
        Dec(Data.FEnchantmentDuration);
        if Data.FEnchantmentDuration = 0 then
          A1.RemoveAbility(FAbilityID);
      end;
    end
    else
      A1.RemoveAbility(FAbilityID);
  end;
end;

procedure TUnitEnchantmentAbility.NewCombatTurn(A1: TCombatObject; A2: Shortint);
var
  Data: TUnitEnchantmentAbilityData;
begin
  if GetDurationMode = dmCombatTurn then
  begin
    Data := TUnitEnchantmentAbilityData(A1.GetAbilityOwner.GetAbilityData(FAbilityID));
    if Data <> nil then
    begin
      if (Data.FEnchantmentDuration > 0) and (A2 = Data.FEnchantmentPlayerIndex) then
      begin
        Dec(Data.FEnchantmentDuration);
        if Data.FEnchantmentDuration = 0 then
          A1.GetAbilityOwner.RemoveAbility(FAbilityID);
      end;
    end
    else
      A1.GetAbilityOwner.RemoveAbility(FAbilityID);
  end;
end;

procedure TUnitEnchantmentAbility.CombatDone(A1: TCombatObject);
begin
  case GetDurationMode of
    dmCombatTurn, dmEntireCombat:
      A1.GetAbilityOwner.RemoveAbility(FAbilityID);
  end;
end;

constructor TUnitEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  { Original ignores the supplied owner. }
  inherited Create(nil);
  FSource := -1;
end;

class function TUnitEnchantment.ClassID: Integer;
begin
  Result := $2130F;
end;

procedure TUnitEnchantment.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FEnchantmentAbilityID, 20);
  Stream.rwInteger(FUnitID, 21);
end;

function TUnitEnchantment.GetName: string;
var
  Source: TAbstractUnit;
begin
  if AoWHSMap <> nil then
  begin
    Source := AoWHSMap.FUnitControl.FindUnit(FUnitID);
    if Source <> nil then
      Result := AoWHSSet.FAbilityControl.GetAbility(FEnchantmentAbilityID).GetName(Source)
    else
      Result := AoWHSSet.FAbilityControl.GetAbility(FEnchantmentAbilityID).GetName(nil);
  end
  else
    Result := AoWHSSet.FAbilityControl.GetAbility(FEnchantmentAbilityID).GetName(nil);
end;

function TUnitEnchantment.GetAIUpkeepPriority: Integer;
var
  Source: TAbstractUnit;
begin
  Source := AoWHSMap.FUnitControl.FindUnit(FUnitID);
  if Source <> nil then
    Result := TUnitEnchantmentAbility(AoWHSSet.FAbilityControl.GetAbility(FEnchantmentAbilityID)).GetAIUpkeepPriority(Source)
  else
    Result := 0;
end;

function TUnitEnchantment.GetBinding: string;
var
  Source: TAbstractUnit;
begin
  Source := AoWHSMap.FUnitControl.FindUnit(FUnitID);
  if Source <> nil then
    Result := Source.GetName
  else
    Result := '';
end;

procedure TUnitEnchantment.Select;
var
  Xhx, Yhx, Lhx: Shortint;
  ArmyHS: TArmyHS;
begin
  GetLocation(Xhx, Yhx, Lhx);
  if Xhx <> -1 then
    if AoWHSMap.Visible(Xhx, Yhx, Lhx, 0) then
    begin
      ArmyHS := TAoWMapField(AoWHSMap.MapContainer.GetField(Xhx, Yhx, Lhx)).GetArmyHS;
      if ArmyHS <> nil then
        AoWHSMap.Select(ArmyHS, True);
    end
    else
      AoWHSMap.ShowMessage(Format(TranslateRStr(XIsOutOfSightRStr), [GetBinding]));
end;

procedure TUnitEnchantment.GetLocation(var A1, A2, A3: Shortint);
var
  Source: TAbstractUnit;
begin
  Source := AoWHSMap.FUnitControl.FindUnit(FUnitID);
  if Source <> nil then
    Source.GetLocation(A1, A2, A3)
  else
  begin
    A1 := -1;
    A2 := -1;
    A3 := -1;
  end;
end;

function TUnitEnchantment.Dispel: Boolean;
var
  Source: TAbstractUnit;
begin
  Source := AoWHSMap.FUnitControl.FindUnit(FUnitID);
  if Source <> nil then
    Result := Source.RemoveAbility(FEnchantmentAbilityID)
  else
    Result := False;
end;

constructor TCosmeticSurgeryEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
end;

class function TCosmeticSurgeryEnchantment.ClassID: Integer;
begin
  Result := $2131C;
end;

procedure TCosmeticSurgeryEnchantment.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FFaceIndex, 25);
end;

function TCosmeticSurgeryEnchantment.GetName: string;
var
  Source: TAbstractUnit;
begin
  Source := AoWHSMap.FUnitControl.FindUnit(FUnitID);
  { Original supplies an argument to the unformatted 'Cosmagic Surgery' text. }
  Result := Format(TranslateRStr(CosmeticSurgeryRStr), [Source.GetName]);
end;

constructor TCosmeticSurgeryAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(CosmeticSurgeryRStr);
  FAbilityID := 126;
end;

function TCosmeticSurgeryAbility.CreateEnchantment: TUnitEnchantment;
begin
  Result := TCosmeticSurgeryEnchantment.Create(nil);
end;

constructor TEnhancementAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityType := atEnhancement;
  FSelectionTypes := [astUnit];
end;

constructor TTransportAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSelectionTypes := [astUnit];
  FMaxLevel := 7;
  FAbilityID := 50;
end;

function TTransportAbility.GetLevelName(A1: Integer): string;
begin
  Result := Format(TranslateRStr(P4TransportUnitsRStr), [IntToStr(A1)]);
end;

class function TLeadershipAbilityData.ClassID: Integer;
begin
  Result := $202CE;
end;

procedure TLeadershipAbilityData.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(FExternalLevel, 25);
  if not (smTextOnly in Stream.StorageMode) then
    Stream.rwString(FExternalSource, 26);
end;

constructor TLeadershipAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FMaxLevel := 1;
  FAbilityID := 46;
  FLevelCosts[1] := 10;
end;

function TLeadershipAbility.AbilityDataClass: TEObjectClass;
begin
  Result := TLeadershipAbilityData;
end;

function TLeadershipAbility.GetLevel(A1: TAbilityOwner): Integer;
var
  Data: TLeadershipAbilityData;
begin
  if A1 <> nil then
  begin
    Data := TLeadershipAbilityData(A1.GetAbilityData(FAbilityID));
    if Data <> nil then
    begin
      if Data.FExternalLevel > Data.FLevel then
        Result := Data.FExternalLevel
      else
        Result := Data.FLevel;
    end
    else
    begin
      Result := 0;
      Exit;
    end;
  end
  else
    Result := 0;
end;

function TLeadershipAbility.GetAttack(A1: TAbilityOwner): Shortint;
var
  Level: Integer;
begin
  Level := GetLevel(A1);
  if Level <> 0 then
    Result := P4LeadershipAttack[Level]
  else
    Result := 0;
end;

function TLeadershipAbility.GetDefense(A1: TAbilityOwner): Shortint;
var
  Level: Integer;
begin
  Level := GetLevel(A1);
  if Level <> 0 then
    Result := P4LeadershipDefense[Level]
  else
    Result := 0;
end;

procedure TLeadershipAbility.SetExternalSource(A1: TAbilityOwner; A2: Byte; SourceName: string);
var
  Data: TLeadershipAbilityData;
begin
  Data := TLeadershipAbilityData(A1.GetAbilityData(FAbilityID));
  if Data = nil then
  begin
    SetAb(A1, FAbilityID, 1);
    Data := TLeadershipAbilityData.Create(nil);
    Data.FLevelAbilityID := FAbilityID;
    Data.FLevel := 0;
    A1.AddAbilityData(Data);
  end;
  { Original compares with the inherent level, even if an external level is higher. }
  if Data.FLevel < A2 then
  begin
    Data.FExternalSource := SourceName;
    Data.FExternalLevel := A2;
  end;
  if A1 is TAbstractUnit then
    A1.Changed;
end;

procedure TLeadershipAbility.ResetExternalSource(A1: TAbilityOwner);
var
  Data: TLeadershipAbilityData;
begin
  Data := TLeadershipAbilityData(A1.GetAbilityData(FAbilityID));
  if Data <> nil then
    if Data.FLevel <> 0 then
    begin
      Data.FExternalSource := '';
      Data.FExternalLevel := 0;
    end
    else
    begin
      SetAb(A1, FAbilityID, 0);
      A1.RemoveAbilityData(Data);
    end;
  if A1 is TAbstractUnit then
    A1.Changed;
end;

function TLeadershipAbility.GetSourceName(A1: TAbilityOwner): string;
var
  Data: TLeadershipAbilityData;
begin
  Data := TLeadershipAbilityData(A1.GetAbilityData(FAbilityID));
  if (Data <> nil) and (Data.FExternalLevel > Data.FLevel) then
    Result := Data.FExternalSource
  else
    Result := A1.GetOwnerName;
end;

function TLeadershipAbility.GetInherent(A1: TAbilityOwner): Boolean;
var
  Data: TLeadershipAbilityData;
begin
  Data := TLeadershipAbilityData(A1.GetAbilityData(FAbilityID));
  Result := (Data <> nil) and (Data.FLevel > 0);
end;

function TLeadershipAbility.CanExpand(A1: TAbilityOwner): Boolean;
var
  Data: TLeadershipAbilityData;
begin
  Data := TLeadershipAbilityData(A1.GetAbilityData(FAbilityID));
  if Data <> nil then
    Result := Data.FLevel < FMaxLevel
  else
    Result := True;
end;

function TLeadershipAbility.GetLevelName(A1: Integer): string;
begin
  Result := TranslateRStr(LeadershipRStr);
end;

class function TStrikeCA.ClassID: Integer;
begin
  Result := $202AA;
end;

procedure TStrikeCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(FStrikeMode, 1, 20);
end;

procedure TStrikeCA.Execute(A1: TCombat);
var
  Source, Target: TCombatObject;
  Data: TUnitEnchantmentAbilityData;
begin
  Source := A1.FCombatData.FindID(FSourceID);
  Target := A1.FCombatData.FindID(FTargetID);
  FDamageDone := Source.DoDamage(Target, FDamage);
  if FEffects.Value <> [] then
    Target.ExecuteDamageEffects(FEffects.Value);
  if (FDamageDone <> 0) and (smLifeStealing in FStrikeMode) and
    (Target is TCombatUnit) and (TCombatUnit(Target).FUnit.GetUnitType <> utMachine) then
      Source.SetHitPoints(Source.GetHitPoints + 1);
  if (smCausedFear in FStrikeMode) and (Target is TCombatUnit) then
    AoWHSSet.FAbilityControl.GetAbility(108).Expand(TCombatUnit(Target).FUnit);
  if (smEntangled in FStrikeMode) and (Target is TCombatUnit) then
  begin
    AoWHSSet.FAbilityControl.GetAbility(94).Expand(TCombatUnit(Target).FUnit);
    Data := TUnitEnchantmentAbilityData(TCombatUnit(Target).FUnit.GetAbilityData(94));
    if Data <> nil then
      Data.FEnchantmentPlayerIndex := Source.FCombatPlayer;
  end;
end;

function TStrikeCA.Play(A1: TCombatViewer): Boolean;
begin
  if A1.FTime = 1 then
    if FDamage = 0 then
      A1.FCombat.FCombatData.FindID(FSourceID).PlaySFX(1)
    else
      A1.FCombat.FCombatData.FindID(FSourceID).PlaySFX(0);
  Result := inherited Play(A1);
end;

procedure TStrikeCA.Generate(A1, A2: TCombatObject; A3, A4: Shortint; A5: TDamageTypes);
begin
  inherited Generate(A1, A2, A3, A4, A5);
  if FDamage <> 0 then
  begin
    if A1.GetAbilityEnabled(51) and not A2.GetAbilityEnabled(67) and
      HitRole(3 - A2.GetResistance) then
        FStrikeMode := FStrikeMode + [smCausedFear];
    if A1.GetAbilityEnabled(119) and HitRole(7 - A2.GetResistance) then
      FStrikeMode := FStrikeMode + [smEntangled];
  end;
end;

constructor TStrikeAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSelectionTypes := [astUnit, astAttackItem];
  FAbilityType := atCombat;
  FAbilityID := 21;
  FAbilityName := TranslateRStr(StrikeRStr);
  FMeleeRound := TMeleeRound.Create;
end;

destructor TStrikeAbility.Destroy;
begin
  FMeleeRound.Free;
  inherited Destroy;
end;

function TStrikeAbility.GetControlType: TAbilityControlType;
begin
  Result := [];
end;

function TStrikeAbility.Remove(A1: TAbilityOwner): Boolean;
var
  I: Integer;
begin
  if A1.GetAbEnabled(21) then
  begin
    inherited Remove(A1);
    for I := A1.GetAbCount - 1 downto 0 do
      if A1.GetAbEnabled(I) then
        if AoWHSSet.FAbilityControl.GetAbility(I) is TStrikeEnhancementAbility then
          while AoWHSSet.FAbilityControl.GetAbility(I).Remove(A1) do;
    Result := True;
  end
  else
    Result := False;
end;

function TStrikeAbility.CanExecuteMelee(A1, A2: TCombatObject): Boolean;
var
  CanAttack: Boolean;
begin
  if A1.GetSide = csDefender then
  begin
    if A1.fcBehindWall and A1.fcWallInBetween(A2.FPosition) then
      CanAttack := wcWallPassing in A2.WallCombatFeatures
    else
      CanAttack := True;
  end
  else
    if A2.fcBehindWall and A1.fcWallInBetween(A2.FPosition) and
      not (wcWallPassing in A1.WallCombatFeatures) then
        CanAttack := False
    else
      CanAttack := True;
  Result := CanAttack and (not A2.GetAbilityEnabled(1) or A1.GetAbilityEnabled(1));
end;

procedure TStrikeAbility.GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes);
var
  Attack, Damage, Repeats: Integer;
begin
  if A1 <> nil then
  begin
    Repeats := 2;
    with TAbstractUnit(A1) do
    begin
      Attack := GetAttack;
      Damage := GetDamage;
      if GetAbilityEnabled(115) then Inc(Repeats);
    end;
    A2 := P4OffensiveStrength(Attack, Damage, Repeats);
    A3 := GetDamageTypes(A1);
  end
  else
  begin
    A2 := 0;
    A3 := [];
  end;
end;

function TStrikeAbility.GetDamageValue(A1, A2: TAbstractUnit): Integer;
begin
  if not A2.GetAbilityEnabled(1) or A1.GetAbilityEnabled(1) then
  begin
    FMeleeRound.CalculateUnit(A1, A2);
    Result := FMeleeRound.GetAttackerDV;
  end
  else
    Result := 0;
end;

procedure TStrikeAbility.GetDamageValueEx(A1, A2: TAbstractUnit; A3: TWallSituation; var A4: TAbilityDamageValues);
begin
  if (A3 = wsNone) and (not A2.GetAbilityEnabled(1) or A1.GetAbilityEnabled(1)) then
  begin
    FMeleeRound.CalculateUnit(A1, A2);
    A4.SourceDamage := FMeleeRound.GetAttackerDV;
    A4.SourceCost := 0;
    A4.TargetDamage := FMeleeRound.GetDefenderDV;
    A4.TargetCost := 0;
    A4.DamageTypes := FMeleeRound.FAttackerDamageTypes - A2.GetImmunityTypes;
  end
  else
  begin
    { Original leaves the cost fields untouched on this path. }
    A4.SourceDamage := 0;
    A4.TargetDamage := 0;
    A4.DamageTypes := [];
  end;
end;

procedure TStrikeAbility.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
begin
  if (A3 = wsNone) and (not A2.GetAbilityEnabled(1) or A1.GetAbilityEnabled(1)) then
  begin
    FMeleeRound.Calculate(A1, A2);
    A4.SourceDamage := FMeleeRound.GetAttackerDV;
    A4.SourceCost := 0;
    A4.TargetDamage := FMeleeRound.GetDefenderDV;
    A4.TargetCost := 0;
    A4.DamageTypes := FMeleeRound.FAttackerDamageTypes - A2.GetImmunityTypes;
  end
  else
  begin
    A4.SourceDamage := 0;
    A4.SourceCost := 0;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [];
  end;
end;

function TStrikeAbility.GetCombatMode(A1: TAbilityOwner): TCombatMode;
begin
  Result := cmMelee;
end;

function TStrikeAbility.GetDamageTypes(A1: TAbilityOwner): TDamageTypes;
begin
  if (A1 is TAbstractUnit) and TAbstractUnit(A1).GetAbilityEnabled(21) then
  begin
    Result := [dtPhysical];
    with TAbstractUnit(A1) do
    begin
      if GetAbilityEnabled(14) or GetAbilityEnabled(163) then Result := Result + [dtFire];
      if GetAbilityEnabled(15) then Result := Result + [dtCold];
      if GetAbilityEnabled(16) then Result := Result + [dtLightning];
      if GetAbilityEnabled(17) then Result := Result + [dtPoison];
    end;
    with TAbstractUnit(A1) do
    begin
      if GetAbilityEnabled(18) or GetAbilityEnabled(169) then Result := Result + [dtDeath];
      if GetAbilityEnabled(19) then Result := Result + [dtHoly];
    end;
    with TAbstractUnit(A1) do
      if GetAbilityEnabled(20) or GetAbilityEnabled(154) then Result := Result + [dtMagic];
  end
  else
    Result := [];
end;

procedure TStrikeAbility.GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo);
begin
  if A1 is TAbstractUnit then
  begin
    with TAbstractUnit(A1) do
    begin
      A2.Attack := GetAttack;
      A2.Damage := GetDamage;
    end;
    A2.DamageTypes := GetDamageTypes(A1);
    A2.RepeatCount := 2;
  end
  else
  begin
    A2.Attack := -1;
    A2.Damage := -1;
    A2.DamageTypes := [dtPhysical];
    A2.RepeatCount := 2;
  end;
end;

function TStrikeAbility.fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean;
var
  Round: TMeleeRound;
  I: Integer;
  Target: TCombatObject;
  Stop: Boolean;
  Action: TCombatAction;
  Strike: TMeleeStrike;
begin
  Target := A2.FTarget;
  Round := TMeleeRound.Create;
  Round.Calculate(A1, Target);
  Stop := False;
  I := 0;
  if A1 is TFastCombatUnit then
  begin
    TFastCombatUnit(A1).FState := TFastCombatUnit(A1).FState + [fsVulnerable];
    if A1.fcBehindWall and A1.fcWallInBetween(Target.FPosition) and
      not (wcWallPassing in Target.WallCombatFeatures) then
    begin
      Action := TMoveWallCA.Create(nil);
      TMoveWallCA(Action).F_MoveWallCA_0C := A1.FID;
      TMoveWallCA(Action).F_MoveWallCA_0D := 0;
      A1.FCombat.ExecuteCombatAction(Action);
      Action.Release;
    end;
  end;
  while (I < Round.FCount) and not Stop do
  begin
    Action := Round.CreateStrikeCA(I);
    if Action <> nil then
    begin
      A1.FCombat.ExecuteCombatAction(Action);
      Round.GetMeleeStrike(I, Strike);
      case Strike.Side of
        csAttacker: Stop := not Target.GetEnabled;
        csDefender: Stop := not A1.GetEnabled;
      end;
      Action.Release;
    end;
    Inc(I);
  end;
  Result := Round.FCount <> 0;
  Round.Free;
end;

procedure TStrikeAbility.fcPrefetchCombatCommands(A1: TFastCombatCommandList);
var
  I: Integer;
  Target: TCombatObject;
  Command: TFastCombatCommand;
  Values: TAbilityDamageValues;
begin
  for I := 0 to A1.FTargetSide.GetCount - 1 do
  begin
    Target := A1.FTargetSide.GetObjects(I);
    if Target.GetEnabled and fcValidRoundDistance(A1.FSource, Target) and
      CanExecuteMelee(A1.FSource, Target) then
    begin
      fcGetDamageValueEx(A1.FSource, Target, wsNone, Values);
      if Values.SourceDamage <> 0 then
      begin
        Command := TFastCombatCommand.Create(FAbilityID);
        Command.FTarget := Target;
        Command.FSourceDV := Values.SourceDamage;
        Command.FTargetDV := Values.TargetDamage;
        Command.FExpectedDV := DVtoDEV(Values.SourceDamage, Values.TargetDamage, A1.FSource, Target);
        { Both original branches assign the same move cost. }
        if Values.TargetDamage = 0 then Command.FMoveCost := 2
        else Command.FMoveCost := 2;
        A1.Add(Command);
      end;
    end;
  end;
end;

constructor TStrikeEnhancementAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityType := atEnhancement;
end;

function TStrikeEnhancementAbility.CanExpand(A1: TAbilityOwner): Boolean;
begin
  Result := inherited CanExpand(A1);
  Result := Result and (A1.GetAbSet(21) or (A1 is TItem));
end;

constructor TMeleeRound.Create;
begin
  inherited Create;
end;

destructor TMeleeRound.Destroy;
begin
  SetCapacity(0);
  inherited Destroy;
end;

procedure TMeleeRound.SetCapacity(A1: Integer);
begin
  FCapacity := A1;
  if FCapacity < FCount then FCount := FCapacity;
  ReallocMem(FStrikes, A1 * SizeOf(TMeleeStrike));
end;

procedure TMeleeRound.SetCount(A1: Integer);
begin
  if A1 > FCapacity then SetCapacity(A1);
  if A1 > FCount then
    FillChar(FStrikes^[FCount], (A1 - FCount) * SizeOf(TMeleeStrike), 0);
  FCount := A1;
end;

procedure TMeleeRound.GetMeleeStrike(A1: Integer; var A2: TMeleeStrike);
begin
  A2 := FStrikes^[A1];
end;

procedure TMeleeRound.Reset;
begin
  SetCount(0);
  FAttacker := nil;
  FDefender := nil;
  FAttackerUnit := nil;
  FDefenderUnit := nil;
  FAttackerDV := -1;
  FDefenderDV := -1;
  FAttackerStrikes := 0;
  FDefenderStrikes := 0;
end;

procedure TMeleeRound.CalculateUnitStrikes(A1: TCombatSideIndex);
var
  I, AttackerCount, DefenderCount: Integer;
  Side: TCombatSideIndex;
  Strike: ^TMeleeStrike;
  Source, Target: TAbstractUnit;
begin
  Side := A1;
  AttackerCount := 0;
  DefenderCount := 0;
  SetCount(FAttackerStrikes + FDefenderStrikes);
  for I := 0 to FCount - 1 do
  begin
    if Side = csAttacker then
    begin
      Source := FAttackerUnit;
      Target := FDefenderUnit;
    end
    else
    begin
      Source := FDefenderUnit;
      Target := FAttackerUnit;
    end;
    Strike := @FStrikes^[I];
    Strike^.Side := Side;
    if (I = 0) or ((I = 1) and (Side <> A1)) then
    begin
      if (Side = csAttacker) and (I = 0) and Source.GetAbilityEnabled(111) then
        Inc(Strike^.DamageBonus, 2);
      if Target.GetAbilityEnabled(113) then
        Dec(Strike^.AttackBonus, 2);
    end;
    if (Source.GetAbilityEnabled(146) or Source.GetAbilityEnabled(160)) and
      (Target.GetAlignment in [alEvil, alPureEvil]) then
    begin
        Inc(Strike^.DamageBonus, 2);
        Inc(Strike^.AttackBonus, 2);
    end;
    if (Source.GetAbilityEnabled(147) or Source.GetAbilityEnabled(161)) and
      (Target.GetAlignment in [alPureGood, alGood]) then
    begin
        Inc(Strike^.DamageBonus, 2);
        Inc(Strike^.AttackBonus, 2);
    end;
    if Source.GetAbilityEnabled(112) and Target.GetAbilityEnabled(63) then
    begin
      Inc(Strike^.AttackBonus, 3);
      Inc(Strike^.DamageBonus, 3);
    end;
    { Original uses the attacker's damage types for both sides. }
    Strike^.DamageValue := StatisticsToDV(Source.GetAttack + Strike^.AttackBonus,
      Source.GetDamage + Strike^.DamageBonus, FAttackerDamageTypes,
      Target.GetDefense, Target.GetResistance, Target.GetImmunityTypes,
      Target.GetProtectionTypes);
    case Side of
      csAttacker:
        begin
          Inc(AttackerCount);
          if FDefenderStrikes <> DefenderCount then Side := csDefender;
        end;
      csDefender:
        begin
          Inc(DefenderCount);
          if FAttackerStrikes <> AttackerCount then Side := csAttacker;
        end;
    end;
  end;
end;

procedure TMeleeRound.CalculateStrikes(A1: TCombatSideIndex);
var
  I, AttackerCount, DefenderCount: Integer;
  Side: TCombatSideIndex;
  Strike: ^TMeleeStrike;
  Source, Target: TCombatObject;
begin
  Side := A1;
  AttackerCount := 0;
  DefenderCount := 0;
  SetCount(FAttackerStrikes + FDefenderStrikes);
  for I := 0 to FCount - 1 do
  begin
    if Side = csAttacker then
    begin
      Source := FAttacker;
      Target := FDefender;
    end
    else
    begin
      Source := FDefender;
      Target := FAttacker;
    end;
    Strike := @FStrikes^[I];
    Strike^.Side := Side;
    if (I = 0) or ((I = 1) and (Side <> A1)) then
    begin
      if (Side = csAttacker) and (I = 0) and Source.GetAbilityEnabled(111) then
        Inc(Strike^.DamageBonus, 2);
      if Target.GetAbilityEnabled(113) then
        Dec(Strike^.AttackBonus, 2);
    end;
    if (Source.GetAbilityEnabled(146) or Source.GetAbilityEnabled(160)) and
      (Target.GetAlignment in [alEvil, alPureEvil]) then
    begin
        Inc(Strike^.AttackBonus, 2);
        Inc(Strike^.DamageBonus, 2);
    end;
    if (Source.GetAbilityEnabled(147) or Source.GetAbilityEnabled(161)) and
      (Target.GetAlignment in [alPureGood, alGood]) then
    begin
        Inc(Strike^.AttackBonus, 2);
        Inc(Strike^.DamageBonus, 2);
    end;
    if Source.GetAbilityEnabled(112) and Target.GetAbilityEnabled(63) then
    begin
      Inc(Strike^.AttackBonus, 3);
      Inc(Strike^.DamageBonus, 3);
    end;
    { Original uses the attacker's damage types for both sides. }
    Strike^.DamageValue := StatisticsToDV(Source.GetAttack + Strike^.AttackBonus,
      Source.GetDamage + Strike^.DamageBonus, FAttackerDamageTypes,
      Target.GetDefense, Target.GetResistance, Target.GetImmunityTypes,
      Target.GetProtectionTypes);
    case Side of
      csAttacker:
        begin
          Inc(AttackerCount);
          if FDefenderStrikes <> DefenderCount then Side := csDefender;
        end;
      csDefender:
        begin
          Inc(DefenderCount);
          if FAttackerStrikes <> AttackerCount then Side := csAttacker;
        end;
    end;
  end;
end;

procedure TMeleeRound.CalculateFreeUnitSwing(A1, A2: TAbstractUnit);
begin
  Reset;
  FAttackerUnit := A1;
  FDefenderUnit := A2;
  FAttackerDamageTypes := TStrikeAbility(AoWHSSet.FAbilityControl.GetAbility(21)).GetDamageTypes(A1);
  FDefenderDamageTypes := [];
  if FAttackerDamageTypes <> [] then
  begin
    FAttackerStrikes := 1;
    CalculateUnitStrikes(csAttacker);
  end;
end;

procedure TMeleeRound.CalculateUnit(A1, A2: TAbstractUnit);
var
  Side: TCombatSideIndex;
begin
  Reset;
  FAttackerUnit := A1;
  FDefenderUnit := A2;
  FAttackerDamageTypes := TStrikeAbility(AoWHSSet.FAbilityControl.GetAbility(21)).GetDamageTypes(A1);
  if FAttackerDamageTypes <> [] then
  begin
    FAttackerStrikes := 2;
    if FAttackerUnit.GetAbilityEnabled(115) then Inc(FAttackerStrikes);
  end
  else
    FAttackerStrikes := 0;
  FDefenderDamageTypes := TStrikeAbility(AoWHSSet.FAbilityControl.GetAbility(21)).GetDamageTypes(A2);
  if FDefenderDamageTypes <> [] then
    FDefenderStrikes := 2
  else
    FDefenderStrikes := 0;
  if FDefenderUnit.GetAbilityEnabled(116) and
    not FAttackerUnit.GetAbilityEnabled(116) and (FDefenderStrikes <> 0) then
    Side := csDefender
  else
    Side := csAttacker;
  CalculateUnitStrikes(Side);
end;

procedure TMeleeRound.Calculate(A1, A2: TCombatObject);
var
  Side: TCombatSideIndex;
begin
  Reset;
  FAttacker := A1;
  FDefender := A2;
  FAttackerDamageTypes := MeleeDamageTypes(A1);
  if (FAttackerDamageTypes <> []) and not A1.GetLocked then
  begin
    FAttackerStrikes := 2;
    if FAttacker.GetAbilityEnabled(115) then Inc(FAttackerStrikes);
  end
  else
    FAttackerStrikes := 0;
  FDefenderDamageTypes := MeleeDamageTypes(A2);
  if (FDefenderDamageTypes <> []) and not A2.GetLocked then
    FDefenderStrikes := 2
  else
    FDefenderStrikes := 0;
  if A2.GetAbilityEnabled(116) and
    not A1.GetAbilityEnabled(116) and (FDefenderStrikes <> 0) then
    Side := csDefender
  else
    Side := csAttacker;
  CalculateStrikes(Side);
end;

procedure TMeleeRound.CalculateSingleSide(A1, A2: TCombatObject);
begin
  Reset;
  FAttacker := A1;
  FDefender := A2;
  FAttackerDamageTypes := MeleeDamageTypes(A1);
  FDefenderDamageTypes := [];
  if (FAttackerDamageTypes <> []) and not FAttacker.GetLocked then
  begin
    FAttackerStrikes := 2;
    if FAttacker.GetAbilityEnabled(115) then Inc(FAttackerStrikes);
  end;
  CalculateStrikes(csAttacker);
end;

function TMeleeRound.CreateStrikeCA(A1: Integer): TStrikeCA;
var
  Strike: ^TMeleeStrike;
begin
  Result := nil;
  if A1 < FCount then
  begin
    Strike := @FStrikes^[A1];
    case Strike^.Side of
      csAttacker:
        if not FAttacker.GetLocked then
        begin
          Result := TStrikeCA.Create(nil);
          Result.Generate(FAttacker, FDefender,
            FAttacker.GetAttack + Strike^.AttackBonus,
            FAttacker.GetDamage + Strike^.DamageBonus, FAttackerDamageTypes);
          if FAttacker.GetAbilityEnabled(118) then
            Result.FStrikeMode := Result.FStrikeMode + [smLifeStealing];
        end;
      csDefender:
        if not FDefender.GetLocked then
        begin
          Result := TStrikeCA.Create(nil);
          Result.SetDefensive(1);
          Result.Generate(FDefender, FAttacker,
            FDefender.GetAttack + Strike^.AttackBonus,
            FDefender.GetDamage + Strike^.DamageBonus, FDefenderDamageTypes);
        end;
    end;
  end;
end;

procedure TMeleeRound.CalculateDV;
var
  I, LifeStealingDV: Integer;
  LifeStealing: Boolean;
  Source: TCombatObject;
begin
  FAttackerDV := 0;
  FDefenderDV := 0;
  I := 0;
  LifeStealingDV := 0;
  Source := FAttacker;
  if Source <> nil then
  begin
    LifeStealing := Source.GetAbilityEnabled(118);
    if LifeStealing and (FDefender is TCombatUnit) and
      (TCombatUnit(FDefender).FUnit.GetUnitType = utMachine) then
      LifeStealing := False;
  end
  else
  begin
    LifeStealing := FAttackerUnit.GetAbilityEnabled(118);
    if LifeStealing and (FDefenderUnit.GetUnitType = utMachine) then
      LifeStealing := False;
  end;
  while I <> FCount do
  begin
    if FStrikes^[I].Side = csAttacker then
    begin
      Inc(FAttackerDV, FStrikes^[I].DamageValue);
      if FStrikes^[I].DamageValue > 100 then
        Inc(LifeStealingDV, 100)
      else
        Inc(LifeStealingDV, FStrikes^[I].DamageValue);
    end
    else
      Inc(FDefenderDV, FStrikes^[I].DamageValue);
    Inc(I);
  end;
  if LifeStealing and (FDefenderDV > 0) then
  begin
    Dec(FDefenderDV, LifeStealingDV);
    if FDefenderDV <= 0 then FDefenderDV := 1;
  end;
end;

function TMeleeRound.GetAttackerDV: Integer;
begin
  if FAttackerDV = -1 then CalculateDV;
  Result := FAttackerDV;
end;

function TMeleeRound.GetDefenderDV: Integer;
begin
  if FDefenderDV = -1 then CalculateDV;
  Result := FDefenderDV;
end;

constructor TTouchAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSelectionTypes := FSelectionTypes + [astUseItem];
  FAbilityType := atCombat;
end;

function TTouchAbility.GetControlType: TAbilityControlType;
begin
  Result := [acCombatAction];
end;

function TTouchAbility.GetTouchAttack(A1: Integer): Shortint;
begin
  Result := -10;
end;

procedure TTouchAbility.GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo);
var
  Attack: Shortint;
  Level: Integer;
begin
  Level := GetLevel(A1);
  Attack := GetTouchAttack(Level);
  A2.Attack := Attack;
  if Attack < 0 then A2.Attack := 0;
  A2.Damage := -1;
  A2.DamageTypes := [];
  A2.RepeatCount := 1;
  A2.Kind := [cmMelee];
end;

function TTouchAbility.GetCombatMode(A1: TAbilityOwner): TCombatMode;
begin
  Result := cmTouch;
end;

function TTouchAbility.TouchRoleProbability(A1, A2: TAbstractUnit): Single;
var
  Attack: Integer;
begin
  Result := HitRoleProbability(A1.GetAttack - A2.GetDefense);
  Attack := GetTouchAttack(GetLevel(A1));
  if Attack <> -10 then
    Result := Result * HitRoleProbability(Attack - A2.GetResistance)
  else
    Result := 0;
end;

function TTouchAbility.CombatTouchRole(A1: TCombatUnit; A2: TCombatObject): Boolean;
var
  Attack: Integer;
begin
  Result := HitRole(A1.GetAttack - A2.GetDefense);
  Attack := GetTouchAttack(GetLevel(A1.FUnit));
  if Result and (Attack <> -10) then
    Result := Result and HitRole(Attack - A2.GetResistance)
  else
    Result := False;
end;

function TTouchAbility.CombatTouchRoleProbability(A1: TCombatUnit; A2: TCombatObject): Single;
var
  Attack: Integer;
begin
  Result := HitRoleProbability(A1.GetAttack - A2.GetDefense);
  Attack := GetTouchAttack(GetLevel(A1.FUnit));
  if Attack <> -10 then
    Result := Result * HitRoleProbability(Attack - A2.GetResistance)
  else
    Result := 0;
end;

function TTouchAbility.CanTouch(A1, A2: TCombatObject): Boolean;
begin
  if A1.GetSide = csDefender then
  begin
    if A1.fcBehindWall and A1.fcWallInBetween(A2.FPosition) then
      Result := wcWallPassing in A2.WallCombatFeatures
    else
      Result := True;
  end
  else
  begin
    if A2.fcBehindWall and A1.fcWallInBetween(A2.FPosition) and
      not (wcWallPassing in A1.WallCombatFeatures) then
      Result := False
    else
      Result := True;
  end;
  if A1.GetSide <> A2.GetSide then
    Result := Result and (not A2.GetAbilityEnabled(1) or A1.GetAbilityEnabled(1));
end;

function TTouchAbility.CanTouchUnit(A1, A2: TAbstractUnit): Boolean;
begin
  if A2.GetAbilityEnabled(1) and not A1.GetAbilityEnabled(1) then
  begin
    Result := False;
    Exit;
  end;
  Result := True;
end;

procedure TTouchAbility.fcValidateMoveOutsideWall(A1, A2: TCombatObject);
var
  Action: TMoveWallCA;
begin
  if A1.fcBehindWall and A1.fcWallInBetween(A2.FPosition) and
    not (wcWallPassing in A2.WallCombatFeatures) then
  begin
    Action := TMoveWallCA.Create(nil);
    Action.F_MoveWallCA_0C := A1.FID;
    Action.F_MoveWallCA_0D := 0;
    A1.FCombat.ExecuteCombatAction(Action);
    Action.Release;
  end;
end;

procedure TTouchAbility.fcPrefetchCombatCommands(A1: TFastCombatCommandList);
var
  I: Integer;
  Target: TCombatObject;
  Command: TFastCombatCommand;
  Values: TAbilityDamageValues;
begin
  for I := 0 to A1.FTargetSide.GetCount - 1 do
  begin
    Target := A1.FTargetSide.GetObjects(I);
    if Target.GetEnabled and CanTouch(A1.FSource, Target) and
      fcValidRoundDistance(A1.FSource, Target) then
    begin
      fcGetDamageValueEx(A1.FSource, Target, wsNone, Values);
      if Values.SourceDamage <> 0 then
      begin
        Command := TFastCombatCommand.Create(FAbilityID);
        Command.FTarget := A1.FTargetSide.GetObjects(I);
        Command.FSourceDV := Values.SourceDamage;
        Command.FTargetDV := Values.TargetDamage;
        Command.FExpectedDV := DVtoDEV(Values.SourceDamage, Values.TargetDamage, A1.FSource, Target);
        if Values.TargetDamage = 0 then Command.FMoveCost := 1
        else Command.FMoveCost := 2;
        A1.Add(Command);
      end;
    end;
  end;
end;

constructor TWallCrushingAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityID := 117;
  FAbilityType := atCombat;
  FAbilityName := TranslateRStr(WallCrushingRStr);
  FSelectionTypes := [astUnit, astAttackItem, astUseItem];
end;

function TWallCrushingAbility.GetDamageValue(A1, A2: TAbstractUnit): Integer;
begin
  Result := StatisticsToLimitedDV(6, 6, [dtWall], A2.GetHitPoints,
    A2.GetDefense, A2.GetResistance, A2.GetImmunityTypes, A2.GetProtectionTypes);
end;

procedure TWallCrushingAbility.GetDamageValueEx(A1, A2: TAbstractUnit; A3: TWallSituation; var A4: TAbilityDamageValues);
begin
  if (A3 = wsNone) then
  begin
    { Original leaves DamageTypes untouched on this successful path. }
    A4.SourceDamage := StatisticsToLimitedDV(6, 6, [dtWall], A2.GetHitPoints,
      A2.GetDefense, A2.GetResistance, A2.GetImmunityTypes, A2.GetProtectionTypes);
    A4.SourceCost := StatisticsToMaxDamage(6, [dtWall], A2.GetImmunityTypes, A2.GetProtectionTypes);
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
  end
  else
  begin
    A4.SourceDamage := 0;
    A4.SourceCost := 0;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [];
  end;
end;

procedure TWallCrushingAbility.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
begin
  if CanTouch(A1, A2) then
  begin
    A4.SourceDamage := StatisticsToLimitedDV(6, 6, [dtWall], A2.GetHitPoints,
      A2.GetDefense, A2.GetResistance, A2.GetImmunityTypes, A2.GetProtectionTypes);
    A4.SourceCost := StatisticsToMaxDamage(6, [dtWall], A2.GetImmunityTypes, A2.GetProtectionTypes);
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
  end
  else
  begin
    A4.SourceDamage := 0;
    A4.SourceCost := 0;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [];
  end;
end;

procedure TWallCrushingAbility.tcGetDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues);
begin
  if CanTouch(A1, A2) then
  begin
    A3.SourceDamage := StatisticsToLimitedDV(6, 6, [dtWall], A2.GetHitPoints,
      A2.GetDefense, A2.GetResistance, A2.GetImmunityTypes, A2.GetProtectionTypes);
    A3.SourceCost := StatisticsToMaxDamage(6, [dtWall], A2.GetImmunityTypes, A2.GetProtectionTypes);
    A3.TargetDamage := 0;
    A3.TargetCost := 0;
  end
  else
  begin
    A3.SourceDamage := 0;
    A3.SourceCost := 0;
    A3.TargetDamage := 0;
    A3.TargetCost := 0;
    A3.DamageTypes := [];
  end;
end;

procedure TWallCrushingAbility.GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo);
begin
  A2.Attack := 6;
  A2.Damage := 6;
  A2.DamageTypes := [dtWall];
  A2.RepeatCount := 1;
  A2.Kind := [];
end;

function TWallCrushingAbility.GetWallCombatFeatures(A1: TAbilityOwner): TWallCombatFeatures;
begin
  Result := [wcWallBreaching, wcParticipate];
end;

function TWallCrushingAbility.fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean;
var
  Target: TCombatObject;
  Action: TDamageCA;
begin
  Target := A2.FTarget;
  if Target.GetEnabled then
  begin
    Action := CreateDamageCA(A1, Target, 6, Boolean(6), [dtWall]);
    A1.FCombat.ExecuteCombatAction(Action);
    Action.Release;
  end;
  Result := True;
end;

procedure TWallCrushingAbility.GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes);
begin
  if A1 <> nil then
  begin
    A2 := P4OffensiveStrength(TAbstractUnit(A1).GetAttack, 6, 1);
    A3 := [dtWall];
  end;
end;

function TWallCrushingAbility.CanTouch(A1, A2: TCombatObject): Boolean;
begin
  Result := inherited CanTouch(A1, A2);
  Result := Result and not (A2 is TCombatUnit);
end;

class function TSelfDestructCA.ClassID: Integer;
begin
  Result := $202B4;
end;

procedure TSelfDestructCA.Execute(A1: TCombat);
var
  Source, Target: TCombatObject;
begin
  Source := A1.FCombatData.FindID(FSourceID);
  Target := A1.FCombatData.FindID(FTargetID);
  FDamageDone := Source.DoDamage(Target, FDamage);
  if FEffects.Value <> [] then Target.ExecuteDamageEffects(FEffects.Value);
  Source.ExecuteDamage(Source.GetHitPoints);
end;

procedure TSelfDestructCA.ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc);
begin
  inherited ShowObject(A1, A2, A3, A4, A5, A6, A7);
  if ((A2.FID = FTargetID) or (A2.FID = FSourceID)) and
    (A1.FTime >= A1.FDelay - 2) then
    AoWHSSet.FAbilityControl.GetAbility(65).FImageSequences.Show(40,
      A5 + 32, A6 + 32, A1.FTime, A7);
end;

constructor TSelfDestructAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityID := 65;
  FAbilityType := atCombat;
  FAbilityName := TranslateRStr(SelfDestructRStr);
  FSelectionTypes := [astUnit];
end;

function TSelfDestructAbility.GetDamageValue(A1, A2: TAbstractUnit): Integer;
begin
  if CanTouchUnit(A1, A2) then
    Result := StatisticsToLimitedDV(8, 6, [dtFire, dtWall], A2.GetHitPoints,
      A2.GetDefense, A2.GetResistance, A2.GetImmunityTypes, A2.GetProtectionTypes)
  else
    Result := 0;
end;

procedure TSelfDestructAbility.GetDamageValueEx(A1, A2: TAbstractUnit; A3: TWallSituation; var A4: TAbilityDamageValues);
begin
  if (A3 = wsNone) and CanTouchUnit(A1, A2) then
  begin
    A4.DamageTypes := [dtFire, dtWall];
    A4.SourceDamage := StatisticsToLimitedDV(8, 6, [dtFire, dtWall], A2.GetHitPoints,
      A2.GetDefense, A2.GetResistance, A2.GetImmunityTypes, A2.GetProtectionTypes);
    A4.SourceCost := StatisticsToMaxDamage(6, [dtFire, dtWall], A2.GetImmunityTypes, A2.GetProtectionTypes);
    A4.TargetDamage := A1.GetHitPoints * 100;
    A4.TargetCost := A1.GetHitPoints;
  end
  else
  begin
    A4.SourceDamage := 0;
    A4.SourceCost := 0;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [];
  end;
end;

procedure TSelfDestructAbility.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
begin
  if (A3 = wsNone) and CanTouch(A1, A2) then
  begin
    A4.DamageTypes := [dtFire, dtWall];
    A4.SourceDamage := StatisticsToLimitedDV(8, 6, [dtFire, dtWall], A2.GetHitPoints,
      A2.GetDefense, A2.GetResistance, A2.GetImmunityTypes, A2.GetProtectionTypes);
    A4.SourceCost := StatisticsToMaxDamage(6, [dtFire, dtWall], A2.GetImmunityTypes, A2.GetProtectionTypes);
    A4.TargetDamage := A1.GetHitPoints * 100;
    A4.TargetCost := A1.GetHitPoints;
  end
  else
  begin
    A4.SourceDamage := 0;
    A4.SourceCost := 0;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [];
  end;
end;

procedure TSelfDestructAbility.GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo);
begin
  A2.Attack := 8;
  A2.Damage := 6;
  A2.DamageTypes := [dtFire, dtWall];
  A2.RepeatCount := -1;
  A2.Kind := [cmMelee];
end;

procedure TSelfDestructAbility.GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes);
begin
  A2 := P4OffensiveStrength(8, 6, 1);
  A3 := [dtFire, dtWall];
end;

function TSelfDestructAbility.GetWallCombatFeatures(A1: TAbilityOwner): TWallCombatFeatures;
begin
  Result := [wcWallBreaching, wcParticipate];
end;

function TSelfDestructAbility.CreateSelfDestructCA(A1, A2: TCombatObject): TSelfDestructCA;
begin
  Result := TSelfDestructCA.Create(nil);
  Result.Generate(A1, A2, 8, 6, [dtFire, dtWall]);
end;

function TSelfDestructAbility.fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean;
var
  Target: TCombatObject;
  Action: TSelfDestructCA;
begin
  Target := A2.FTarget;
  fcValidateMoveOutsideWall(A1, Target);
  Action := CreateSelfDestructCA(A1, Target);
  A1.FCombat.ExecuteCombatAction(Action);
  Action.Release;
  Result := True;
end;

function TSelfDestructAbility.CanTouch(A1, A2: TCombatObject): Boolean;
begin
  if A1.GetSide = csDefender then
  begin
    if A1.fcBehindWall and A1.fcWallInBetween(A2.FPosition) then
      Result := wcWallPassing in A2.WallCombatFeatures
    else
    begin
      Result := True;
      Exit;
    end;
  end
  else
  begin
    if A2.fcBehindWall and A1.fcWallInBetween(A2.FPosition) and
      not (wcWallPassing in A1.WallCombatFeatures) then
      Result := False
    else
      Result := True;
  end;
end;

function TSelfDestructAbility.CanTouchUnit(A1, A2: TAbstractUnit): Boolean;
begin
  Result := True;
end;

{ Anonymous unit-strike damage helper at $55766468. }
function P4UnitStrikeDV(Source, Target: TAbstractUnit): Integer;
begin
  TStrikeAbility(AoWHSSet.FAbilityControl.GetAbility(21)).FMeleeRound.CalculateFreeUnitSwing(Source, Target);
  Result := TStrikeAbility(AoWHSSet.FAbilityControl.GetAbility(21)).FMeleeRound.GetAttackerDV;
end;

constructor TRoundAttackAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityID := 114;
  FAbilityType := atCombat;
  FAbilityName := TranslateRStr(RoundAttackRStr);
end;

procedure TRoundAttackAbility.GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes);
var
  Attack, Damage: Integer;
begin
  if A1 <> nil then
  begin
    with TAbstractUnit(A1) do
    begin
      Attack := GetAttack;
      Damage := GetDamage;
    end;
    A2 := P4OffensiveStrength(Attack, Damage, 1) * 3;
    A3 := TStrikeAbility(AoWHSSet.FAbilityControl.GetAbility(21)).GetDamageTypes(A1);
  end;
end;

function TRoundAttackAbility.GetDamageValue(A1, A2: TAbstractUnit): Integer;
begin
  if CanTouchUnit(A1, A2) then
    Result := P4UnitStrikeDV(A1, A2) * 2
  else
    Result := 0;
end;

procedure TRoundAttackAbility.GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo);
var
  Source: TAbstractUnit;
begin
  if A1 is TAbstractUnit then
  begin
    Source := TAbstractUnit(A1);
    A2.Attack := Source.GetAttack;
    A2.Damage := Source.GetDamage;
    A2.DamageTypes := TStrikeAbility(AoWHSSet.FAbilityControl.GetAbility(21)).GetDamageTypes(Source);
    A2.RepeatCount := 2;
    A2.Kind := [cmMelee];
    Exit;
  end
  else
  begin
    A2.Attack := -1;
    A2.Damage := -1;
    A2.DamageTypes := [dtPhysical];
    A2.RepeatCount := 2;
    A2.Kind := [cmMelee];
  end;
end;

procedure TRoundAttackAbility.GetDamageValueEx(A1, A2: TAbstractUnit; A3: TWallSituation; var A4: TAbilityDamageValues);
begin
  if (A3 = wsNone) and CanTouchUnit(A1, A2) then
  begin
    A4.SourceDamage := P4UnitStrikeDV(A1, A2) * 2;
    A4.SourceCost := 0;
    A4.TargetDamage := P4UnitStrikeDV(A1, A2);
    A4.TargetCost := 0;
    A4.DamageTypes := TStrikeAbility(AoWHSSet.FAbilityControl.GetAbility(21)).GetDamageTypes(A1) - A2.GetImmunityTypes;
  end
  else
  begin
    A4.SourceDamage := 0;
    A4.SourceCost := 0;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [];
  end;
end;

procedure TRoundAttackAbility.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
var
  Count, I: Integer;
  DamageTypes: TDamageTypes;
  Combat: TFastCombat;
  Target: TCombatObject;
begin
  if (A3 = wsNone) and CanTouch(A1, A2) then
  begin
    DamageTypes := MeleeDamageTypes(A1);
    A4.SourceDamage := StrikeDV(A1, A2);
    A4.SourceCost := A1.GetDamage;
    A4.TargetDamage := StrikeDV(A2, A1);
    A4.TargetCost := A2.GetDamage;
    A4.DamageTypes := DamageTypes - A2.GetImmunityTypes;
    Combat := TFastCombat(A1.FCombat);
    Count := 0;
    for I := Combat.FSides[A2.GetSide].GetCount - 1 downto 0 do
    begin
      Target := Combat.FSides[A2.GetSide].GetObjects(I);
      { Original tests A2's flying ability here, rather than Target's. }
      if (Target <> A2) and Target.GetEnabled and
        (Target.FPosition shr 4 = A2.FPosition shr 4) and
        (not A2.GetAbilityEnabled(1) or A1.GetAbilityEnabled(1)) and
        not A1.fcWallInBetween(Target.FPosition) and
        (Target.fcRoundDistance <= Combat.GetRoundDistance) and
        (DamageTypes - Target.GetImmunityTypes <> []) then
        Inc(Count);
    end;
    if Count <> 0 then
    begin
      if Count > 3 then Count := 3;
      Inc(A4.SourceDamage, Round(A4.SourceDamage * Count / 3));
    end;
  end
  else
  begin
    A4.SourceDamage := 0;
    A4.SourceCost := 0;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [];
  end;
end;

procedure TRoundAttackAbility.tcGetDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues);
begin
  if CanTouch(A1, A2) then
  begin
    A3.SourceDamage := StrikeDV(A1, A2) * 2;
    A3.SourceCost := A1.GetDamage * 2;
    { Original repeats the forward strike instead of reversing the arguments. }
    A3.TargetDamage := StrikeDV(A1, A2);
    A3.TargetCost := A2.GetDamage;
    A3.DamageTypes := MeleeDamageTypes(A1) - A2.GetImmunityTypes;
  end
  else
  begin
    A3.SourceDamage := 0;
    A3.SourceCost := 0;
    A3.TargetDamage := 0;
    A3.TargetCost := 0;
    A3.DamageTypes := [];
  end;
end;

function TRoundAttackAbility.fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean;
var
  DamageTypes: TDamageTypes;
  I, Count: Integer;
  Action: TStrikeCA;
  Combat: TCombat;
  Targets: TList;
  Target, Other: TCombatObject;
  MoveAction: TMoveWallCA;
begin
  Combat := A1.FCombat;
  Targets := TList.Create;
  DamageTypes := MeleeDamageTypes(A1);
  Target := A2.FTarget;
  fcValidateMoveOutsideWall(A1, Target);
  if A1 is TFastCombatUnit then
  begin
    TFastCombatUnit(A1).FRoundDistance := 0;
    if A1.fcBehindWall and A1.fcWallInBetween(Target.FPosition) and
      not (wcWallPassing in Target.WallCombatFeatures) then
    begin
      MoveAction := TMoveWallCA.Create(nil);
      MoveAction.F_MoveWallCA_0C := A1.FID;
      MoveAction.F_MoveWallCA_0D := 0;
      A1.FCombat.ExecuteCombatAction(MoveAction);
      MoveAction.Release;
    end;
  end;
  Action := AoWE.CreateStrikeCA(A1, Target, False);
  if Action <> nil then
  begin
    Combat.ExecuteCombatAction(Action);
    Action.Release;
  end;
  for I := Combat.FSides[Target.GetSide].GetCount - 1 downto 0 do
  begin
    Other := Combat.FSides[Target.GetSide].GetObjects(I);
    if (Other <> Target) and Other.GetEnabled and
      (Other.FPosition shr 4 = Target.FPosition shr 4) and
      (not Other.GetAbilityEnabled(1) or A1.GetAbilityEnabled(1)) and
      not A1.fcWallInBetween(Other.FPosition) and
      (Other.fcRoundDistance <= Combat.GetRound - 1) and
      (DamageTypes - Other.GetImmunityTypes <> []) then
      Targets.Add(Other);
  end;
  Count := AoWHSMap.Random(2) + 1;
  while (Count <> 0) and (Targets.Count <> 0) do
  begin
    Other := Targets[AoWHSMap.Random(Targets.Count)];
    Action := AoWE.CreateStrikeCA(A1, Other, False);
    if Action <> nil then
    begin
      Combat.ExecuteCombatAction(Action);
      Action.Release;
    end;
    Targets.Remove(Other);
    Dec(Count);
  end;
  Targets.Free;
  Result := True;
end;

class function TPossessCA.ClassID: Integer;
begin
  Result := $202B5;
end;

procedure TPossessCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwBool(FSuccessful, 20);
end;

procedure TPossessCA.Initialize(A1, A2: Byte; A3: Boolean);
begin
  FSourceID := A1;
  FTargetID := A2;
  FSuccessful := A3;
end;

procedure TPossessCA.Execute(A1: TCombat);
var
  Source, Target: TCombatUnit;
  NewUnit, OldUnit: TAbstractUnit;
  Data: TPossessedAbilityData;
  Experience, I: Integer;
begin
  if FSuccessful then
  begin
    Source := TCombatUnit(A1.FCombatData.FindID(FSourceID));
    Target := TCombatUnit(A1.FCombatData.FindID(FTargetID));
    for I := 0 to 2 do
      TCommandAbility(AoWHSSet.FAbilityControl.GetAbility(CommandAbilityIDs[I])).ResetCommandedUnits(Target);
    for I := 0 to 2 do
      TCommandAbility(AoWHSSet.FAbilityControl.GetAbility(CommandAbilityIDs[I])).Uncommand(Target);
    NewUnit := Target.FUnit;
    NewUnit.AddRef;
    Target.SetUnit(nil);
    Target.DestroyObject;
    OldUnit := Source.FUnit;
    OldUnit.AddRef;
    OldUnit.Killed;
    OldUnit.SetOwner(nil);
    Source.SetUnit(NewUnit);
    if usMoving in OldUnit.FUnitStatus then
      Source.FUnit.FUnitStatus := Source.FUnit.FUnitStatus + [usMoving];
    AoWHSSet.FAbilityControl.GetAbility(107).Expand(Source.FUnit);
    if OldUnit.GetAbilityEnabled(107) then
    begin
      Data := TPossessedAbilityData(OldUnit.GetAbilityData(107));
      if Data <> nil then
        Experience := Data.FSourceExperience
      else
        Experience := 0;
    end
    else
      Experience := OldUnit.GetExperience;
    Data := TPossessedAbilityData(Source.FUnit.GetAbilityData(107));
    if Data <> nil then
      Data.FSourceExperience := Source.FUnit.GetUnitLevel + Experience;
    NewUnit.Release;
    OldUnit.Release;
  end;
end;

procedure TPossessCA.ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc);
begin
  inherited ShowObject(A1, A2, A3, A4, A5, A6, A7);
  if (A2.FID = FSourceID) or (A2.FID = FTargetID) then
    AoWHSSet.FAbilityControl.GetAbility(106).FImageSequences.Show(0,
      A5 + 32, A6 + 32, A1.FTime, A7);
end;

function TPossessCA.Play(A1: TCombatViewer): Boolean;
begin
  if A1.FTime = 0 then
    AoWHSSet.FAbilityControl.GetAbility(106).FSFXLibrary.Play(0);
  if A1.FDelay = A1.FTime then
    Execute(A1.FCombat);
  Result := A1.FDelay * 2 > A1.FTime;
end;

class function TPossessedAbilityData.ClassID: Integer;
begin
  Result := $202D5;
end;

function TPossessedAbilityData.GetAbilityID: Integer;
begin
  Result := 107;
end;

procedure TPossessedAbilityData.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FSourceExperience, 30);
end;

constructor TPossessedAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityID := 107;
  FAbilityName := TranslateRStr(PossessedRStr);
  FAbilityType := atEnchantment;
  FSelectionTypes := [];
end;

procedure TPossessedAbility.CombatObjectDestroyed(A1: TCombatObject);
var
  NewUnit: TUnit;
  Data: TPossessedAbilityData;
begin
  with TCombatUnit(A1) do
  begin
    SetStatus(FStatus - [csDestroyed]);
    NewUnit := TUnit.Create(nil);
    NewUnit.SetUnitResource(AoWHSSet.FUnitResources.GetUnitResource(152));
    Data := TPossessedAbilityData(FUnit.GetAbilityData(107));
    if Data <> nil then
      NewUnit.SetExperience(Data.FSourceExperience);
    if usMoving in FUnit.FUnitStatus then
      NewUnit.FUnitStatus := [usMoving] + NewUnit.FUnitStatus;
    FUnit.Killed;
    SetUnit(NewUnit);
    NewUnit.Release;
  end;
end;

function TPossessedAbility.AbilityDataClass: TEObjectClass;
begin
  Result := P4PossessedDataClass;
end;

function TPossessedAbility.Expand(A1: TAbilityOwner): Boolean;
var
  Data: TPossessedAbilityData;
begin
  Result := False;
  Data := TPossessedAbilityData(A1.GetAbilityData(FAbilityID));
  if Data = nil then
  begin
    Data := TPossessedAbilityData.Create(nil);
    SetAb(A1, FAbilityID, 1);
    A1.AddAbilityData(Data);
    Result := True;
  end;
end;

function TPossessedAbility.Remove(A1: TAbilityOwner): Boolean;
var
  Data: TPossessedAbilityData;
begin
  Result := True;
  Data := TPossessedAbilityData(A1.GetAbilityData(FAbilityID));
  if Data <> nil then
  begin
    SetAb(A1, FAbilityID, 0);
    A1.RemoveAbilityData(Data);
  end
  else
    SetAb(A1, FAbilityID, 0);
end;

constructor TPossessAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityID := 106;
  FAbilityName := TranslateRStr(PossessRStr);
  FSelectionTypes := [astUnit];
end;

function TPossessAbility.GetTouchAttack(A1: Integer): Shortint;
begin
  Result := 5;
end;

function TPossessAbility.CreatePossessCA(A1, A2: TCombatObject): TPossessCA;
begin
  Result := TPossessCA.Create(nil);
  Result.Initialize(A1.FID, A2.FID, CombatTouchRole(TCombatUnit(A1), A2));
end;

function TPossessAbility.CanTouch(A1, A2: TCombatObject): Boolean;
begin
  Result := inherited CanTouch(A1, A2);
  if Result then
    Result := (A1 is TCombatUnit) and (A2 is TCombatUnit) and
      not A2.GetAbilityEnabled(106) and
      (TCombatUnit(A2).FUnit.GetUnitType <> utMachine) and
      not (TCombatUnit(A2).FUnit is THero);
end;

function TPossessAbility.CanTouchUnit(A1, A2: TAbstractUnit): Boolean;
begin
  Result := inherited CanTouchUnit(A1, A2);
  { Original excludes humanoids here, but machines in CanTouch. }
  Result := Result and not A2.GetAbilityEnabled(106) and
    (A2.GetUnitType <> utHumanoid) and not (A2 is THero);
end;

procedure TPossessAbility.GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes);
begin
  if A1 <> nil then
  begin
    A2 := Round(TAbstractUnit(A1).GetAttack * 25 * 0.1);
    A3 := [dtNone];
  end;
end;

function TPossessAbility.GetDamageValue(A1, A2: TAbstractUnit): Integer;
var
  Probability: Single;
begin
  if CanTouchUnit(A1, A2) and not (dtNone in A2.GetImmunityTypes) then
  begin
    Probability := TouchRoleProbability(A1, A2);
    Result := Round(A2.GetHitPoints * Probability * 200);
  end
  else
    Result := 0;
end;

procedure TPossessAbility.GetDamageValueEx(A1, A2: TAbstractUnit; A3: TWallSituation; var A4: TAbilityDamageValues);
var
  Probability: Single;
begin
  if (A3 = wsNone) and CanTouchUnit(A1, A2) and not (dtNone in A2.GetImmunityTypes) then
  begin
    Probability := TouchRoleProbability(A1, A2);
    A4.SourceDamage := Round(A2.GetHitPoints * Probability * 200);
    if A1.GetAbilityEnabled(106) then
      A4.TargetDamage := 0
    else
      A4.TargetDamage := Round(A1.GetHitPoints * Probability * 100);
    { Original leaves both cost fields untouched on success. }
    A4.DamageTypes := [];
  end
  else
  begin
    A4.SourceDamage := 0;
    A4.SourceCost := 0;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [];
  end;
end;

procedure TPossessAbility.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
var
  Probability: Single;
begin
  if (A3 = wsNone) and CanTouch(A1, A2) then
  begin
    Probability := CombatTouchRoleProbability(TCombatUnit(A1), A2);
    A4.SourceDamage := Round(A2.GetHitPoints * Probability * 200);
    A4.SourceCost := A2.GetHitPoints * 2;
    if A1.GetAbilityEnabled(106) then
      A4.TargetDamage := 0
    else
      A4.TargetDamage := Round(A1.GetHitPoints * Probability * 100);
    A4.TargetCost := A2.GetDamage;
    A4.DamageTypes := [];
  end
  else
  begin
    A4.SourceDamage := 0;
    A4.SourceCost := 0;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [];
  end;
end;

function TPossessAbility.fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean;
var
  Target: TCombatObject;
  Action: TPossessCA;
  Strike: TStrikeCA;
begin
  Target := A2.FTarget;
  fcValidateMoveOutsideWall(A1, Target);
  Action := CreatePossessCA(A1, Target);
  A1.FCombat.ExecuteCombatAction(Action);
  if not Action.FSuccessful then
  begin
    Strike := AoWE.CreateStrikeCA(Target, A1, True);
    if Strike <> nil then
    begin
      A1.FCombat.ExecuteCombatAction(Strike);
      Strike.Release;
    end;
  end;
  Action.Release;
  Result := True;
end;

class function TWebCA.ClassID: Integer;
begin
  Result := $202B8;
end;

procedure TWebCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwBool(FSuccessful, 20);
end;

procedure TWebCA.Initialize(A1: Byte; A2: Byte; A3: Boolean);
begin
  FSourceID := A1;
  FTargetID := A2;
  FSuccessful := A3;
end;

procedure TWebCA.Execute(A1: TCombat);
var
  Target: TCombatUnit;
begin
  if FSuccessful then
  begin
    Target := TCombatUnit(A1.FCombatData.FindID(FTargetID));
    AoWHSSet.FAbilityControl.GetAbility(97).Expand(Target.FUnit);
  end;
end;

procedure TWebCA.ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc);
begin
  inherited ShowObject(A1, A2, A3, A4, A5, A6, A7);
  if A2.FID = FTargetID then
    AoWHSSet.FAbilityControl.GetAbility(27).FImageSequences.Show(0,
      A5 + 32, A6 + 32, A1.FTime, A7);
end;

function TWebCA.Play(A1: TCombatViewer): Boolean;
begin
  if A1.FTime = 0 then
    AoWHSSet.FAbilityControl.GetAbility(27).FSFXLibrary.Play(0);
  if A1.FDelay = A1.FTime then
    Execute(A1.FCombat);
  Result := A1.FDelay * 2 > A1.FTime;
end;

constructor TWebAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityID := 27;
  FAbilityName := TranslateRStr(WebRStr);
  FSelectionTypes := [astUnit];
end;

function TWebAbility.GetTouchAttack(A1: Integer): Shortint;
begin
  Result := 4;
end;

function TWebAbility.CreateWebCA(A1, A2: TCombatObject): TWebCA;
begin
  Result := TWebCA.Create(nil);
  Result.Initialize(A1.FID, A2.FID, CombatTouchRole(TCombatUnit(A1), A2));
end;

function TWebAbility.CanTouch(A1, A2: TCombatObject): Boolean;
begin
  Result := inherited CanTouch(A1, A2);
  if Result then
    Result := (A1 is TCombatUnit) and (A2 is TCombatUnit) and
      not A2.GetAbilityEnabled(97);
end;

procedure TWebAbility.GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes);
begin
  if A1 <> nil then
  begin
    A2 := Round(TAbstractUnit(A1).GetAttack * 4 * 4 * 0.1);
    A3 := [dtNone];
  end;
end;

function TWebAbility.GetDamageValue(A1, A2: TAbstractUnit): Integer;
var
  Probability: Single;
begin
  if (not A2.GetAbilityEnabled(1) or A1.GetAbilityEnabled(1)) and
    not (dtNone in A2.GetImmunityTypes) then
  begin
    Probability := TouchRoleProbability(A1, A2);
    Result := Round(A2.GetHitPoints * Probability * 100);
  end
  else
    Result := 0;
end;

procedure TWebAbility.GetDamageValueEx(A1, A2: TAbstractUnit; A3: TWallSituation; var A4: TAbilityDamageValues);
var
  Probability: Single;
begin
  if (A3 = wsNone) and (not A2.GetAbilityEnabled(1) or A1.GetAbilityEnabled(1)) and
    not (dtNone in A2.GetImmunityTypes) then
  begin
    Probability := TouchRoleProbability(A1, A2);
    A4.SourceDamage := Round(A2.GetHitPoints * Probability * 100);
    A4.SourceCost := A2.GetHitPoints;
    A4.TargetDamage := Round(P4UnitStrikeDV(A2, A1) * (1 - Probability));
    A4.TargetCost := A2.GetDamage;
    A4.DamageTypes := [];
  end
  else
  begin
    A4.SourceDamage := 0;
    A4.SourceCost := 0;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [];
  end;
end;

procedure TWebAbility.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
var
  Probability: Single;
begin
  if (A3 = wsNone) and CanTouch(A1, A2) then
  begin
    Probability := CombatTouchRoleProbability(TCombatUnit(A1), A2);
    A4.SourceDamage := Round(A2.GetHitPoints * Probability * 100);
    A4.SourceCost := A2.GetHitPoints;
    A4.TargetDamage := Round(StrikeDV(A2, A1) * (1 - Probability));
    A4.TargetCost := StatisticsToMaxDamage(A2.GetDamage, MeleeDamageTypes(A2),
      A1.GetImmunityTypes, A1.GetProtectionTypes);
    A4.DamageTypes := [];
  end
  else
  begin
    A4.SourceDamage := 0;
    A4.SourceCost := 0;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [];
  end;
end;

function TWebAbility.fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean;
var
  Target: TCombatObject;
  Action: TWebCA;
  Strike: TStrikeCA;
begin
  Target := A2.FTarget;
  fcValidateMoveOutsideWall(A1, Target);
  Action := CreateWebCA(A1, Target);
  A1.FCombat.ExecuteCombatAction(Action);
  if not Action.FSuccessful then
  begin
    Strike := AoWE.CreateStrikeCA(Target, A1, True);
    if Strike <> nil then
    begin
      A1.FCombat.ExecuteCombatAction(Strike);
      Strike.Release;
    end;
  end;
  Action.Release;
  Result := True;
end;

class function TEntangleCA.ClassID: Integer;
begin
  Result := $202BE;
end;

procedure TEntangleCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwBool(FSuccessful, 20);
end;

procedure TEntangleCA.Initialize(A1: Byte; A2: Byte; A3: Boolean);
begin
  FSourceID := A1;
  FTargetID := A2;
  FSuccessful := A3;
end;

procedure TEntangleCA.Execute(A1: TCombat);
var
  Source, Target: TCombatUnit;
  Data: TUnitEnchantmentAbilityData;
begin
  if FSuccessful then
  begin
    Source := TCombatUnit(A1.FCombatData.FindID(FSourceID));
    Target := TCombatUnit(A1.FCombatData.FindID(FTargetID));
    AoWHSSet.FAbilityControl.GetAbility(94).Expand(Target.FUnit);
    Data := TUnitEnchantmentAbilityData(Target.FUnit.GetAbilityData(94));
    if Data <> nil then
      Data.FEnchantmentPlayerIndex := Source.FCombatPlayer;
  end;
end;

procedure TEntangleCA.ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc);
begin
  inherited ShowObject(A1, A2, A3, A4, A5, A6, A7);
  if A2.FID = FTargetID then
    AoWHSSet.FAbilityControl.GetAbility(40).FImageSequences.Show(0,
      A5 + 32, A6 + 32, A1.FTime, A7);
end;

function TEntangleCA.Play(A1: TCombatViewer): Boolean;
begin
  if A1.FTime = 0 then
    AoWHSSet.FAbilityControl.GetAbility(40).FSFXLibrary.Play(0);
  if A1.FDelay = A1.FTime then
    Execute(A1.FCombat);
  Result := A1.FDelay * 2 > A1.FTime;
end;

constructor TEntangleAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityID := 40;
  FAbilityName := TranslateRStr(EntangleRStr);
  FSelectionTypes := [astUnit, astUseItem];
end;

function TEntangleAbility.GetTouchAttack(A1: Integer): Shortint;
begin
  Result := 7;
end;

function TEntangleAbility.CreateEntangleCA(A1, A2: TCombatObject): TEntangleCA;
begin
  Result := TEntangleCA.Create(nil);
  Result.Initialize(A1.FID, A2.FID, CombatTouchRole(TCombatUnit(A1), A2));
end;

function TEntangleAbility.CanTouch(A1, A2: TCombatObject): Boolean;
begin
  Result := inherited CanTouch(A1, A2);
  if Result then
    Result := (A1 is TCombatUnit) and (A2 is TCombatUnit) and
      not A2.GetAbilityEnabled(94);
end;

procedure TEntangleAbility.GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes);
begin
  if A1 <> nil then
  begin
    A2 := Round(TAbstractUnit(A1).GetAttack * 7 * 5 * 0.1);
    A3 := [dtNone];
  end;
end;

function TEntangleAbility.GetDamageValue(A1, A2: TAbstractUnit): Integer;
var
  Probability: Single;
begin
  if CanTouchUnit(A1, A2) and
    not (dtNone in A2.GetImmunityTypes) then
  begin
    Probability := TouchRoleProbability(A1, A2);
    Result := Round(A2.GetHitPoints * Probability * 100);
  end
  else
    Result := 0;
end;

procedure TEntangleAbility.GetDamageValueEx(A1, A2: TAbstractUnit; A3: TWallSituation; var A4: TAbilityDamageValues);
var
  Probability: Single;
begin
  if (A3 = wsNone) and CanTouchUnit(A1, A2) and
    not (dtNone in A2.GetImmunityTypes) then
  begin
    Probability := TouchRoleProbability(A1, A2);
    A4.SourceDamage := Round(A2.GetHitPoints * Probability * 100);
    A4.SourceCost := A2.GetHitPoints;
    A4.TargetDamage := Round(P4UnitStrikeDV(A2, A1) * (1 - Probability));
    A4.TargetCost := A2.GetDamage;
    A4.DamageTypes := [];
  end
  else
  begin
    A4.SourceDamage := 0;
    A4.SourceCost := 0;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [];
  end;
end;

procedure TEntangleAbility.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
var
  Probability: Single;
begin
  if (A3 = wsNone) and CanTouch(A1, A2) then
  begin
    Probability := CombatTouchRoleProbability(TCombatUnit(A1), A2);
    A4.SourceDamage := Round(A2.GetHitPoints * Probability * 100);
    A4.SourceCost := A2.GetHitPoints;
    A4.TargetDamage := Round(StrikeDV(A2, A1) * (1 - Probability));
    A4.TargetCost := StatisticsToMaxDamage(A2.GetDamage, MeleeDamageTypes(A2),
      A1.GetImmunityTypes, A1.GetProtectionTypes);
    A4.DamageTypes := [];
  end
  else
  begin
    A4.SourceDamage := 0;
    A4.SourceCost := 0;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [];
  end;
end;

function TEntangleAbility.fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean;
var
  Target: TCombatObject;
  Action: TEntangleCA;
  Strike: TStrikeCA;
begin
  Target := A2.FTarget;
  fcValidateMoveOutsideWall(A1, Target);
  Action := CreateEntangleCA(A1, Target);
  A1.FCombat.ExecuteCombatAction(Action);
  if not Action.FSuccessful then
  begin
    Strike := AoWE.CreateStrikeCA(Target, A1, True);
    if Strike <> nil then
    begin
      A1.FCombat.ExecuteCombatAction(Strike);
      Strike.Release;
    end;
  end;
  Action.Release;
  Result := True;
end;

class function TTurnUndeadCA.ClassID: Integer;
begin
  Result := $202B9;
end;

function TTurnUndeadCA.GetSuccessfull: Boolean;
begin
  Result := FDamage <> 0;
end;

procedure TTurnUndeadCA.Execute(A1: TCombat);
var
  Source, Target: TCombatUnit;
  Data: TUnitEnchantmentAbilityData;
begin
  inherited Execute(A1);
  if FDamage <> 0 then
  begin
    Source := TCombatUnit(A1.FCombatData.FindID(FSourceID));
    Target := TCombatUnit(A1.FCombatData.FindID(FTargetID));
    if not (csDestroyed in Target.FStatus) then
    begin
      AoWHSSet.FAbilityControl.GetAbility(34).Expand(Target.FUnit);
      with Target do
        Data := TUnitEnchantmentAbilityData(FUnit.GetAbilityData(34));
      if Data <> nil then
        Data.FEnchantmentPlayerIndex := Source.FCombatPlayer;
    end;
  end;
end;

procedure TTurnUndeadCA.ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc);
begin
  inherited ShowObject(A1, A2, A3, A4, A5, A6, A7);
  if A2.FID = FTargetID then
    AoWHSSet.FAbilityControl.GetAbility(38).FImageSequences.Show(0,
      A5 + 32, A6 + 32, A1.FTime, A7);
end;

function TTurnUndeadCA.Play(A1: TCombatViewer): Boolean;
begin
  Result := inherited Play(A1);
  if A1.FTime = 0 then
    AoWHSSet.FAbilityControl.GetAbility(38).FSFXLibrary.Play(0);
end;

constructor TTurnUndeadAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityID := 38;
  FSelectionTypes := [astUnit, astHeadItem, astTorsoItem, astDefenseItem,
    astRingItem, astUseItem, astEditor];
  FAbilityName := TranslateRStr(TurnUndeadRStr);
  FAbilityType := atCombat;
end;

function TTurnUndeadAbility.CanTouchUnit(A1, A2: TAbstractUnit): Boolean;
begin
  Result := inherited CanTouchUnit(A1, A2);
  if Result then
    Result := (A2.GetUnitType in [utHumanoid, utCreature]) and
      ((Word(A2.GetRace) = 11) or A2.GetAbilityEnabled(129));
end;

function TTurnUndeadAbility.CanTouch(A1, A2: TCombatObject): Boolean;
begin
  Result := inherited CanTouch(A1, A2);
  if Result then
    Result := (A1 is TCombatUnit) and (A2 is TCombatUnit) and
      (TCombatUnit(A2).FUnit.GetUnitType in [utHumanoid, utCreature]) and
      ((Word(TCombatUnit(A2).FUnit.GetRace) = 11) or
        TCombatUnit(A2).FUnit.GetAbilityEnabled(129));
end;

function TTurnUndeadAbility.GetLevel(A1: TAbilityOwner): Integer;
var
  Data: TMultiLevelAbilityData;
begin
  if A1 <> nil then
  begin
    Data := TMultiLevelAbilityData(A1.GetAbilityData(FAbilityID));
    if Data <> nil then
      Result := Data.FLevel
    else
    begin
      Result := 0;
      Exit;
    end;
  end
  else
    Result := 0;
end;

function TTurnUndeadAbility.AbilityDataClass: TEObjectClass;
begin
  Result := P4MultiLevelDataClass;
end;

procedure TTurnUndeadAbility.GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes);
var
  Damage: Integer;
begin
  if A1 <> nil then
  begin
    Damage := GetTurnUndeadDamage(GetLevel(A1));
    if Damage > 5 then Damage := 5;
    A2 := Round(TAbstractUnit(A1).GetAttack * 4 * Damage * 0.1);
    { Original reports death damage here, although the attack deals holy damage. }
    A3 := [dtDeath];
  end;
end;

function TTurnUndeadAbility.GetLevelName(A1: Integer): string;
begin
  case A1 of
    0: Result := TranslateRStr(TurnUndeadRStr);
    1: Result := TranslateRStr(TurnUndeadRStr) + ' I';
    2: Result := TranslateRStr(TurnUndeadRStr) + ' II';
    3: Result := TranslateRStr(TurnUndeadRStr) + ' III';
    4: Result := TranslateRStr(TurnUndeadRStr) + ' IV';
  end;
end;

function TTurnUndeadAbility.GetName(A1: TAbilityOwner): string;
begin
  Result := GetLevelName(GetLevel(A1));
end;

function TTurnUndeadAbility.ExpandName(A1: TAbilityOwner): string;
begin
  Result := GetLevelName(GetLevel(A1) + 1);
end;

function TTurnUndeadAbility.ExpandCost(A1: TAbilityOwner): Integer;
begin
  if GetLevel(A1) < 4 then Result := 5
  else Result := 0;
end;

function TTurnUndeadAbility.CanExpand(A1: TAbilityOwner): Boolean;
begin
  if (A1.GetAbilitySelectionTypes * FSelectionTypes = []) or (GetLevel(A1) >= 4) then
  begin
    Result := False;
    Exit;
  end;
  Result := True;
end;

function TTurnUndeadAbility.GetSkillPoints(A1: TAbilityOwner): Integer;
begin
  Result := GetLevel(A1) * 5;
end;

function TTurnUndeadAbility.Expand(A1: TAbilityOwner): Boolean;
var
  Data: TMultiLevelAbilityData;
begin
  Result := False;
  Data := TMultiLevelAbilityData(A1.GetAbilityData(FAbilityID));
  if Data = nil then
  begin
    Data := TMultiLevelAbilityData.Create(nil);
    Data.FLevelAbilityID := FAbilityID;
    Data.FLevel := 1;
    SetAb(A1, FAbilityID, 1);
    A1.AddAbilityData(Data);
    Result := True;
  end
  else if Data.FLevel <> 4 then
  begin
    Result := True;
    Inc(Data.FLevel);
  end;
end;

function TTurnUndeadAbility.Remove(A1: TAbilityOwner): Boolean;
var
  Data: TMultiLevelAbilityData;
begin
  Result := True;
  Data := TMultiLevelAbilityData(A1.GetAbilityData(FAbilityID));
  if Data <> nil then
  begin
    if Data.FLevel = 1 then
    begin
      SetAb(A1, FAbilityID, 0);
      A1.RemoveAbilityData(Data);
    end
    else
      Dec(Data.FLevel);
  end
  else
  begin
    SetAb(A1, FAbilityID, 0);
    Result := False;
  end;
end;

function TTurnUndeadAbility.GetTouchAttack(A1: Integer): Shortint;
begin
  case A1 of
    1: Result := 4;
    2: Result := 5;
    3: Result := 6;
    4: Result := 7;
  else
    Result := 4;
  end;
end;

function TTurnUndeadAbility.GetTurnUndeadDamage(A1: Integer): Shortint;
begin
  case A1 of
    1: Result := 4;
    2: Result := 5;
    3: Result := 6;
    4: Result := 7;
  else
    Result := 0;
  end;
end;

procedure TTurnUndeadAbility.GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo);
var
  Level: Integer;
begin
  Level := GetLevel(A1);
  A2.Attack := GetTouchAttack(Level);
  A2.Damage := GetTurnUndeadDamage(Level);
  A2.DamageTypes := [dtHoly];
  A2.RepeatCount := 1;
  A2.Kind := [cmMelee];
end;

function TTurnUndeadAbility.GetDamageValue(A1, A2: TAbstractUnit): Integer;
var
  Probability: Single;
begin
  if CanTouchUnit(A1, A2) and not (dtNone in A2.GetImmunityTypes) then
  begin
    Probability := TouchRoleProbability(A1, A2);
    Result := Round(A2.GetHitPoints * Probability * 100);
  end
  else
    Result := 0;
end;

procedure TTurnUndeadAbility.GetDamageValueEx(A1, A2: TAbstractUnit; A3: TWallSituation; var A4: TAbilityDamageValues);
var
  Probability: Single;
  HitPoints: Integer;
begin
  if (A3 = wsNone) and CanTouchUnit(A1, A2) and not (dtNone in A2.GetImmunityTypes) then
  begin
    Probability := TouchRoleProbability(A1, A2);
    HitPoints := A2.GetHitPoints;
    A4.SourceCost := HitPoints;
    A4.SourceDamage := Round(HitPoints * Probability * 100);
    A4.TargetDamage := Round(P4UnitStrikeDV(A2, A1) * (1 - Probability));
    A4.TargetCost := StatisticsToMaxDamage(A2.GetDamage,
      TStrikeAbility(AoWHSSet.FAbilityControl.GetAbility(21)).GetDamageTypes(A2),
      A1.GetImmunityTypes, A1.GetProtectionTypes);
    A4.DamageTypes := [dtHoly];
  end
  else
  begin
    A4.SourceDamage := 0;
    A4.SourceCost := 0;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [];
  end;
end;

procedure TTurnUndeadAbility.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
var
  Probability: Single;
  HitPoints: Integer;
begin
  if (A3 = wsNone) and CanTouch(A1, A2) then
  begin
    Probability := CombatTouchRoleProbability(TCombatUnit(A1), A2);
    HitPoints := A2.GetHitPoints;
    A4.SourceCost := HitPoints;
    A4.SourceDamage := Round(HitPoints * Probability * 100);
    A4.TargetDamage := Round(StrikeDV(A2, A1) * (1 - Probability));
    A4.TargetCost := StatisticsToMaxDamage(A2.GetDamage, MeleeDamageTypes(A2),
      A1.GetImmunityTypes, A1.GetProtectionTypes);
    A4.DamageTypes := [dtHoly];
  end
  else
  begin
    A4.SourceDamage := 0;
    A4.SourceCost := 0;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [];
  end;
end;

function TTurnUndeadAbility.CreateTurnUndeadCA(A1, A2: TCombatObject): TTurnUndeadCA;
var
  Action: TTurnUndeadCA;
  Level: Integer;
begin
  Action := TTurnUndeadCA.Create(nil);
  if HitRole(A1.GetAttack - A2.GetDefense) then
  begin
    Level := A1.GetAbilityLevel(FAbilityID);
    Action.GenerateEx(A1, A2, GetTouchAttack(Level), GetTurnUndeadDamage(Level), [dtHoly], 1);
  end
  else
  begin
    Action.FSourceID := A1.FID;
    Action.FTargetID := A2.FID;
  end;
  Result := Action;
end;

function TTurnUndeadAbility.fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean;
var
  Target: TCombatObject;
  Action: TTurnUndeadCA;
  Strike: TStrikeCA;
begin
  Target := A2.FTarget;
  fcValidateMoveOutsideWall(A1, Target);
  Action := CreateTurnUndeadCA(A1, Target);
  A1.FCombat.ExecuteCombatAction(Action);
  if Target.GetEnabled then
  begin
    Strike := AoWE.CreateStrikeCA(Target, A1, True);
    if Strike <> nil then
    begin
      A1.FCombat.ExecuteCombatAction(Strike);
      Strike.Release;
    end;
  end;
  Action.Release;
  Result := True;
end;

class function TInvokeDeathCA.ClassID: Integer;
begin
  Result := $202C4;
end;

procedure TInvokeDeathCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwBool(FSuccessful, 20);
end;
procedure TInvokeDeathCA.ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc);
begin
  inherited ShowObject(A1, A2, A3, A4, A5, A6, A7);
  if A2.FID = FTargetID then
    AoWHSSet.FAbilityControl.GetAbility(35).FImageSequences.Show(0,
      A5 + 32, A6 + 32, A1.FTime, A7);
end;
function TInvokeDeathCA.Play(A1: TCombatViewer): Boolean;
begin
  if A1.FTime = 0 then
    AoWHSSet.FAbilityControl.GetAbility(35).FSFXLibrary.Play(0);
  if A1.FDelay = A1.FTime then
    Execute(A1.FCombat);
  Result := A1.FDelay * 2 > A1.FTime;
end;
procedure TInvokeDeathCA.Execute(A1: TCombat);
var
  Source, Target: TCombatObject;
begin
  if FSuccessful then
  begin
    Source := A1.FCombatData.FindID(FSourceID);
    Target := A1.FCombatData.FindID(FTargetID);
    Source.DoDamage(Target, Target.GetHitPoints);
  end;
end;

procedure TInvokeDeathCA.Initialize(A1: Byte; A2: Byte; A3: Boolean);
begin
  FSourceID := A1;
  FTargetID := A2;
  FSuccessful := A3;
end;

constructor TInvokeDeathAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityID := 35;
  FAbilityName := TranslateRStr(InvokeDeathRStr);
  FSelectionTypes := [astUnit, astUseItem];
end;

procedure TInvokeDeathAbility.GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo);
begin
  A2.Attack := GetTouchAttack(1);
  A2.Damage := -1;
  A2.DamageTypes := [dtDeath];
  A2.RepeatCount := 1;
  A2.Kind := [cmMelee];
end;

function TInvokeDeathAbility.GetTouchAttack(A1: Integer): Shortint;
begin
  Result := 6;
end;

procedure TInvokeDeathAbility.GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes);
begin
  if A1 <> nil then
  begin
    A2 := Round(TAbstractUnit(A1).GetAttack * 6 * 5 * 0.1);
    A3 := [dtDeath];
  end;
end;

function TInvokeDeathAbility.GetDamageValue(A1, A2: TAbstractUnit): Integer;
var
  Probability: Single;
begin
  if (not A2.GetAbilityEnabled(1) or A1.GetAbilityEnabled(1)) and not (dtNone in A2.GetImmunityTypes) then
  begin
    Probability := TouchRoleProbability(A1, A2);
    Result := Round(A2.GetHitPoints * Probability * 100);
  end
  else
    Result := 0;
end;
procedure TInvokeDeathAbility.GetDamageValueEx(A1, A2: TAbstractUnit; A3: TWallSituation; var A4: TAbilityDamageValues);
var
  Probability: Single;
  HitPoints: Integer;
begin
  if (A3 = wsNone) and (not A2.GetAbilityEnabled(1) or A1.GetAbilityEnabled(1)) and not (dtNone in A2.GetImmunityTypes) then
  begin
    Probability := TouchRoleProbability(A1, A2);
    HitPoints := A2.GetHitPoints;
    A4.SourceCost := HitPoints;
    A4.SourceDamage := Round(HitPoints * Probability * 100);
    A4.TargetDamage := Round(P4UnitStrikeDV(A2, A1) * (1 - Probability));
    A4.TargetCost := StatisticsToMaxDamage(A2.GetDamage,
      TStrikeAbility(AoWHSSet.FAbilityControl.GetAbility(21)).GetDamageTypes(A2),
      A1.GetImmunityTypes, A1.GetProtectionTypes);
    A4.DamageTypes := [dtDeath];
  end
  else
  begin
    A4.SourceDamage := 0;
    A4.SourceCost := 0;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [];
  end;
end;
procedure TInvokeDeathAbility.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
var
  Probability: Single;
  HitPoints: Integer;
begin
  if (A3 = wsNone) and CanTouch(A1, A2) then
  begin
    Probability := CombatTouchRoleProbability(TCombatUnit(A1), A2);
    HitPoints := A2.GetHitPoints;
    A4.SourceCost := HitPoints;
    A4.SourceDamage := Round(HitPoints * Probability * 100);
    A4.TargetDamage := Round(StrikeDV(A2, A1) * (1 - Probability));
    A4.TargetCost := StatisticsToMaxDamage(A2.GetDamage, MeleeDamageTypes(A2),
      A1.GetImmunityTypes, A1.GetProtectionTypes);
    A4.DamageTypes := [dtDeath];
  end
  else
  begin
    A4.SourceDamage := 0;
    A4.SourceCost := 0;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [];
  end;
end;
function TInvokeDeathAbility.CreateCA(A1, A2: TCombatObject): TInvokeDeathCA;
begin
  Result := TInvokeDeathCA.Create(nil);
  Result.Initialize(A1.FID, A2.FID, CombatTouchRole(TCombatUnit(A1), A2));
end;

function TInvokeDeathAbility.fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean;
var
  Target: TCombatObject;
  Action: TInvokeDeathCA;
  Strike: TStrikeCA;
begin
  Target := A2.FTarget;
  fcValidateMoveOutsideWall(A1, Target);
  Action := CreateCA(A1, Target);
  A1.FCombat.ExecuteCombatAction(Action);
  if Target.GetEnabled then
  begin
    Strike := AoWE.CreateStrikeCA(Target, A1, True);
    if Strike <> nil then
    begin
      A1.FCombat.ExecuteCombatAction(Strike);
      Strike.Release;
    end;
  end;
  Action.Release;
  Result := True;
end;
function TInvokeDeathAbility.CanTouchUnit(A1, A2: TAbstractUnit): Boolean;
begin
  Result := inherited CanTouchUnit(A1, A2);
  if Result then
    Result := (A2.GetUnitType in [utHumanoid, utCreature]) and
      (Word(A2.GetRace) <> 11) and not A2.GetAbilityEnabled(129);
end;
function TInvokeDeathAbility.CanTouch(A1, A2: TCombatObject): Boolean;
begin
  Result := inherited CanTouch(A1, A2);
  if Result then
    Result := (A2 is TCombatUnit) and
      (TCombatUnit(A2).FUnit.GetUnitType in [utHumanoid, utCreature]) and
      (Word(TCombatUnit(A2).FUnit.GetRace) <> 11) and
      not TCombatUnit(A2).FUnit.GetAbilityEnabled(129);
end;
class function THealingCA.ClassID: Integer;
begin
  Result := $202BD;
end;

procedure THealingCA.Initialize(A1: Byte; A2: Byte);
begin
  FSourceID := A1;
  FTargetID := A2;
end;

procedure THealingCA.Execute(A1: TCombat);
var
  Source, Target: TCombatUnit;
begin
  Source := TCombatUnit(A1.FCombatData.FindID(FSourceID));
  Target := TCombatUnit(A1.FCombatData.FindID(FTargetID));
  THealingAbility(AoWHSSet.FAbilityControl.GetAbility(47)).SetEnabled(Source.FUnit, False);
  THealingAbility(AoWHSSet.FAbilityControl.GetAbility(47)).HealUnit(Target.FUnit);
end;

procedure THealingCA.ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc);
begin
  inherited ShowObject(A1, A2, A3, A4, A5, A6, A7);
  if A2.FID = FTargetID then
    AoWHSSet.FAbilityControl.GetAbility(47).FImageSequences.Show(0,
      A5 + 32, A6 + 32, A1.FTime, A7);
end;
function THealingCA.Play(A1: TCombatViewer): Boolean;
begin
  if A1.FTime = 0 then
    AoWHSSet.FAbilityControl.GetAbility(47).FSFXLibrary.Play(0);
  if A1.FDelay = A1.FTime then
    Execute(A1.FCombat);
  Result := A1.FDelay * 2 > A1.FTime;
end;
class function THealingAbilityData.ClassID: Integer;
begin
  Result := $202AE;
end;

function THealingAbilityData.GetAbilityID: Integer;
begin
  Result := 47;
end;

procedure THealingAbilityData.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwBool(FEnabled, 10);
end;

constructor THealingAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityID := 47;
  FAbilityName := TranslateRStr(HealingRStr);
  FSelectionTypes := [astUnit, astUseItem, astEditor];
  FAbilityType := atEnhancement;
end;

function THealingAbility.GetControlType: TAbilityControlType;
begin
  Result := [acAction, acCombatAction];
end;

procedure THealingAbility.SetEnabled(A1: TAbilityOwner; A2: Boolean);
var
  Data: THealingAbilityData;
begin
  Data := THealingAbilityData(A1.GetAbilityData(FAbilityID));
  if Data = nil then
  begin
    Data := THealingAbilityData.Create(nil);
    A1.AddAbilityData(Data);
  end;
  Data.FEnabled := A2;
end;

function THealingAbility.GetEnabled(A1: TAbilityOwner): Boolean;
var
  Data: THealingAbilityData;
begin
  Result := A1.GetAbSet(FAbilityID);
  if Result then
  begin
    Data := THealingAbilityData(A1.GetAbilityData(FAbilityID));
    if Data <> nil then
      Result := Data.FEnabled
    else
      Result := True;
  end;
end;

procedure THealingAbility.NewTurn(A1: TAbilityOwner; A2: Shortint);
begin
  if (A1 is TAbstractUnit) and (TAbstractUnit(A1).FPlayer = A2) then
    SetEnabled(A1, True);
end;

function THealingAbility.AbilityDataClass: TEObjectClass;
begin
  Result := P4HealingDataClass;
end;

function THealingAbility.GetName(A1: TAbilityOwner): string;
begin
  if (A1 = nil) or GetEnabled(A1) then
    Result := FAbilityName
  else
    Result := FAbilityName + ' (' + LowerCase(TranslateRStr(UsedRStr)) + ')';
end;

function THealingAbility.Remove(A1: TAbilityOwner): Boolean;
begin
  Result := inherited Remove(A1);
  if Result then A1.RemoveAbilityDataID(FAbilityID);
end;

function THealingAbility.GetHealHitPoints(A1: TCombatObject): Integer;
begin
  Result := Shortint(A1.GetHits) - A1.GetHitPoints;
  if Result > 5 then Result := 5;
end;

function THealingAbility.CreateHealingCA(A1, A2: TCombatObject): THealingCA;
begin
  Result := THealingCA.Create(nil);
  Result.Initialize(A1.FID, A2.FID);
end;

function THealingAbility.CanTouchUnit(A1, A2: TAbstractUnit): Boolean;
begin
  Result := inherited CanTouchUnit(A1, A2);
  if Result then
    Result := (A2.GetUnitType in [utHumanoid, utCreature]) and
      ((A2.GetHits <> A2.GetHitPoints) or A2.GetAbilityEnabled(96) or
        A2.GetAbilityEnabled(53) or A2.GetAbilityEnabled(108));
end;

function THealingAbility.CanTouch(A1, A2: TCombatObject): Boolean;
begin
  Result := inherited CanTouch(A1, A2);
  if Result then
    Result := (A1 is TCombatUnit) and (A2 is TCombatUnit) and
      (TCombatUnit(A2).FUnit.GetUnitType in [utHumanoid, utCreature]) and
      ((A2.GetHits <> Byte(A2.GetHitPoints)) or A2.GetAbilityEnabled(96) or
        A2.GetAbilityEnabled(53) or A2.GetAbilityEnabled(108));
end;

procedure THealingAbility.GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo);
begin
  inherited GetCombatInfo(A1, A2);
  A2.Kind := [cmNone];
end;

function THealingAbility.GetDamageValue(A1, A2: TAbstractUnit): Integer;
begin
  if not (dtNone in A2.GetImmunityTypes) then
  begin
    Result := A2.GetHits - A2.GetHitPoints;
    if Result > 5 then Result := 5;
    Result := Result * 100;
    Exit;
  end;
  Result := 0;
end;

procedure THealingAbility.GetDamageValueEx(A1, A2: TAbstractUnit; A3: TWallSituation; var A4: TAbilityDamageValues);
begin
  if (A3 = wsNone) and not (dtNone in A2.GetImmunityTypes) then
  begin
    A4.SourceCost := A2.GetHits - A2.GetHitPoints;
    if A4.SourceCost > 5 then A4.SourceCost := 5;
    A4.SourceDamage := A4.SourceCost * 100;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [dtNone];
  end
  else
  begin
    A4.SourceDamage := 0;
    A4.SourceCost := 0;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [];
  end;
end;

procedure THealingAbility.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
var
  HitPoints: Integer;
begin
  if (A3 = wsNone) and CanTouch(A1, A2) then
  begin
    HitPoints := GetHealHitPoints(A2);
    A4.SourceCost := HitPoints;
    A4.SourceDamage := HitPoints * 100;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [dtNone];
  end
  else
  begin
    A4.SourceDamage := 0;
    A4.SourceCost := 0;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [];
  end;
end;

function THealingAbility.HealUnit(A1: TAbstractUnit): Boolean;
var
  HitPoints: Integer;
begin
  Result := False;
  if A1.GetHits <> A1.GetHitPoints then
  begin
    HitPoints := A1.GetHits - A1.GetHitPoints;
    if HitPoints > 5 then HitPoints := 5;
    A1.SetHitPoints(A1.GetHitPoints + Shortint(HitPoints));
    Result := True;
  end;
  if A1.GetAbilityEnabled(96) then
  begin
    A1.RemoveAbility(96);
    Result := True;
  end;
  if A1.GetAbilityEnabled(53) then
  begin
    A1.RemoveAbility(53);
    Result := True;
  end;
  if A1.GetAbilityEnabled(108) then
  begin
    A1.RemoveAbility(108);
    Result := True;
  end;
  A1.Changed;
end;

function THealingAbility.fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean;
var
  Target: TCombatObject;
  Action: THealingCA;
begin
  Target := A2.FTarget;
  fcValidateMoveOutsideWall(A1, Target);
  Action := CreateHealingCA(A1, Target);
  A1.FCombat.ExecuteCombatAction(Action);
  Action.Release;
  Result := True;
end;

procedure THealingAbility.fcPrefetchCombatCommands(A1: TFastCombatCommandList);
var
  I: Integer;
  Target: TCombatObject;
  Command: TFastCombatCommand;
  Values: TAbilityDamageValues;
begin
  for I := 0 to A1.FSourceSide.GetCount - 1 do
  begin
    Target := A1.FSourceSide.GetObjects(I);
    if Target.GetEnabled and CanTouch(A1.FSource, Target) then
    begin
      fcGetDamageValueEx(A1.FSource, Target, wsNone, Values);
      if Values.SourceDamage <> 0 then
      begin
        Command := TFastCombatCommand.Create(FAbilityID);
        Command.FTarget := Target;
        Command.FSourceDV := Values.SourceDamage;
        Command.FTargetDV := 0;
        Command.FExpectedDV := DVtoDEV(Values.SourceDamage, 0, A1.FSource, Target);
        Command.FMoveCost := 0;
        A1.Add(Command);
      end;
    end;
  end;
end;

function THealingAbility.Activate(A1: TAbilityOwner; var A2: string): Boolean;
var
  Info: TUnitSelectorAAI;
  Selector: THealingUnitSelector;
begin
  if CanActivate(A1, A2) then
  begin
    Info := TUnitSelectorAAI.Create(nil);
    Info.FAbilityID := FAbilityID;
    if A1 is TAbstractUnit then Info.FUnitID := TAbstractUnit(A1).FUnitID
    else Info.FUnitID := 0;
    Selector := THealingUnitSelector.Create;
    Selector.FCaption := Format(TranslateRStr(SelectUnitForXRStr), [TranslateRStr(HealingRStr)]);
    Selector.Setup(A1, TUnitList(A1.Owner));
    Info.SetUnitSelector(Selector);
    { Original omits Selector.Release here. }
    AoWHSMap.FOnActivateAbility.TriggerNotifyEvents(Info);
    Info.Release;
    Result := True;
  end
  else Result := False;
end;

class function THealingTE.ClassID: Integer;
begin
  Result := $202F2;
end;

procedure THealingTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FSourceID, 25);
  Stream.rwByte(FSourcePlayer, 26);
  Stream.rwInteger(FTargetID, 27);
  Stream.rwByte(FTargetPlayer, 28);
end;

function THealingTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
var
  Source, Target: TAbstractUnit;
  Ability: THealingAbility;
  Anim: TImageSequenceAnimation;
  X, Y, L: Shortint;
begin
  inherited Execute(TE);
  Source := AoWHSMap.FUnitControl.FindUnit(FSourceID);
  Target := AoWHSMap.FUnitControl.FindUnit(FTargetID);
  if (Source <> nil) and (Byte(Source.FPlayer) = FSourcePlayer) and
    (Target <> nil) and (Byte(Target.FPlayer) = FTargetPlayer) then
  begin
    Ability := THealingAbility(AoWHSSet.FAbilityControl.GetAbility(47));
    if Ability.GetEnabled(Source) then
    begin
      Ability.SetEnabled(Source, False);
      Ability.HealUnit(Target);
      Target.GetLocation(X, Y, L);
      AoWHSMap.ValidateObservation(FSourcePlayer, X, Y, L, 0);
      if AoWHSMap.Visible(X, Y, L, 0) then
      begin
        Anim := TImageSequenceAnimation.Create(nil);
        Anim.SetImageSequence(Ability.FImageSequences.GetImageSequence(0));
        AoWHSMap.PlaceHX(Anim, X, Y, L);
      end;
      if (Byte(AoWHSMap.FSeatedPlayer) = FSourcePlayer) or AoWHSMap.Watching(X, Y, L, 0) then
        Ability.FSFXLibrary.Play(0);
    end;
    Result := erDone;
  end
  else Result := erDoneHalt;
end;

function THealingUnitSelector.CanSelectUnit(A1: TUnit): Boolean;
begin
  if not ((A1.GetUnitType in [utHumanoid, utCreature]) and
    (A1.GetHits <> A1.GetHitPoints)) then
  begin
    Result := False;
    Exit;
  end;
  Result := True;
end;

function THealingUnitSelector.Select: Boolean;
var
  Source, Target: TAbstractUnit;
  Error: string;
  I: Integer;
  Event: THealingTE;
begin
  Source := AoWHSMap.FUnitControl.FindUnit(FSourceUnitID);
  if CanSelect(Error) and not AoWHSMap.FPlayers.GetPlayers(Source.FPlayer).GetBusy then
  begin
    I := 0;
    Target := nil;
    while (Target = nil) and (I <> FUnits.GetCount) do
    begin
      if (FSelection and (1 shl I)) <> 0 then Target := FUnits.GetUnit(I);
      Inc(I);
    end;
    if Target <> nil then
    begin
      Event := THealingTE.Create(nil);
      Event.FSourceID := Source.FUnitID;
      Event.FSourcePlayer := Source.FPlayer;
      Event.FTargetID := Target.FUnitID;
      Event.FTargetPlayer := Target.FPlayer;
      AoWHSMap.FTokenManager.GetTokenControl(Source.FPlayer).AddEvent(Event);
      Event.Release;
      Result := True;
    end
    else Result := False;
  end
  else Result := False;
end;

constructor TDispelMagicCA.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FEnchantmentIDs := TIntegerList.Create;
end;

destructor TDispelMagicCA.Destroy;
begin
  FEnchantmentIDs.Free;
  inherited Destroy;
end;

procedure TDispelMagicCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwStreamProc(50, FEnchantmentIDs.LoadFromStream, FEnchantmentIDs.SaveToStream);
end;

procedure TDispelMagicCA.Execute(A1: TCombat);
var
  Enchantments: TEnchantmentList;
  Source, Target: TCombatObject;
  I: Integer;
  Enchantment: TEnchantment;
  WasSummoned: Boolean;
begin
  Source := A1.FCombatData.FindID(FSourceID);
  Target := A1.FCombatData.FindID(FTargetID);
  if (Source is TCombatUnit) and (Target is TCombatUnit) then
  begin
    Enchantments := TEnchantmentList.Create(nil);
    with TCombatUnit(Target) do
    begin
      FUnit.ListEnchantments(Enchantments);
      WasSummoned := FUnit.GetAbilityEnabled(155);
    end;
    for I := FEnchantmentIDs.Count - 1 downto 0 do
    begin
      Enchantment := Enchantments.FindID(FEnchantmentIDs[I]);
      if Enchantment <> nil then Enchantment.Dispel;
    end;
    if WasSummoned and not TCombatUnit(Target).FUnit.GetAbilityEnabled(155) then
      Source.DoDamage(Target, Target.GetHitPoints);
    Enchantments.Free;
  end;
end;

procedure TDispelMagicCA.ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc);
begin
  inherited ShowObject(A1, A2, A3, A4, A5, A6, A7);
  if A2.FID = FTargetID then
    AoWHSSet.FAbilityControl.GetAbility(60).FImageSequences.Show(0,
      A5 + 32, A6 + 32, A1.FTime, A7);
end;
function TDispelMagicCA.Play(A1: TCombatViewer): Boolean;
begin
  if A1.FTime = 0 then
    AoWHSSet.FAbilityControl.GetAbility(60).FSFXLibrary.Play(0);
  if A1.FDelay = A1.FTime then
    Execute(A1.FCombat);
  Result := A1.FDelay * 2 > A1.FTime;
end;
procedure TDispelMagicCA.Generate(A1, A2: TCombatObject; A3: Integer);
var
  Enchantments: TEnchantmentList;
  I, Chance: Integer;
begin
  FSourceID := A1.FID;
  FTargetID := A2.FID;
  if (A1 is TCombatUnit) and (A2 is TCombatUnit) then
  begin
    Enchantments := TEnchantmentList.Create(nil);
    TCombatUnit(A2).FUnit.ListEnchantments(Enchantments);
    for I := Enchantments.GetCount - 1 downto 0 do
    begin
      Chance := Enchantments.GetEnchantments(I).DispelChance(A3);
      if Chance > AoWHSMap.Random(100) then
        FEnchantmentIDs.Add(Enchantments.GetEnchantments(I).FEnchantmentID);
    end;
    Enchantments.Free;
  end;
end;

class function TDispelMagicAbilityCA.ClassID: Integer;
begin
  Result := $202BF;
end;

procedure TDispelMagicAbilityCA.Execute(A1: TCombat);
var
  Source: TCombatUnit;
begin
  inherited Execute(A1);
  Source := TCombatUnit(A1.FCombatData.FindID(FSourceID));
  TDispelMagicAbility(AoWHSSet.FAbilityControl.GetAbility(60)).SetEnabled(Source.FUnit, False);
end;

class function TDispelMagicAbilityData.ClassID: Integer;
begin
  Result := $202CD;
end;

function TDispelMagicAbilityData.GetAbilityID: Integer;
begin
  Result := 60;
end;

procedure TDispelMagicAbilityData.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwBool(FEnabled, 10);
  Stream.rwByte(FLevel, 11);
end;

constructor TDispelMagicAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityID := 60;
  FAbilityName := TranslateRStr(DispelMagicRStr);
  FSelectionTypes := [astUnit, astUseItem, astEditor];
  FAbilityType := atEnhancement;
end;
function TDispelMagicAbility.GetControlType: TAbilityControlType;
begin
  Result := [acAction, acCombatAction];
end;
procedure TDispelMagicAbility.SetEnabled(A1: TAbilityOwner; A2: Boolean);
var
  Data: TDispelMagicAbilityData;
begin
  Data := TDispelMagicAbilityData(A1.GetAbilityData(FAbilityID));
  if Data = nil then
  begin
    Data := TDispelMagicAbilityData.Create(nil);
    A1.AddAbilityData(Data);
  end;
  Data.FEnabled := A2;
end;
function TDispelMagicAbility.GetEnabled(A1: TAbilityOwner): Boolean;
var
  Data: TDispelMagicAbilityData;
begin
  Result := A1.GetAbSet(FAbilityID);
  if Result then
  begin
    Data := TDispelMagicAbilityData(A1.GetAbilityData(FAbilityID));
    if Data <> nil then
      Result := Data.FEnabled
    else
      Result := True;
  end;
end;
procedure TDispelMagicAbility.GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo);
begin
  inherited;
  A2.Kind := [cmNone, cmMelee];
end;
procedure TDispelMagicAbility.NewTurn(A1: TAbilityOwner; A2: Shortint);
begin
  if (A1 is TAbstractUnit) and (TAbstractUnit(A1).FPlayer = A2) then
    SetEnabled(A1, True);
end;
function TDispelMagicAbility.AbilityDataClass: TEObjectClass;
begin
  Result := P4DispelMagicDataClass;
end;
function TDispelMagicAbility.GetDispelMana(A1: TAbilityOwner): Integer;
begin
  Result := GetLevel(A1) * 10 + 20;
end;

function TDispelMagicAbility.GetLevel(A1: TAbilityOwner): Integer;
var
  Data: TDispelMagicAbilityData;
begin
  if A1 <> nil then
  begin
    if A1.GetAbSet(60) then
    begin
      Data := TDispelMagicAbilityData(A1.GetAbilityData(FAbilityID));
      if Data <> nil then Result := Data.FLevel
      else Result := 1;
    end
    else
    begin
      Result := 0;
      Exit;
    end;
  end
  else Result := 0;
end;

function TDispelMagicAbility.GetLevelName(A1: Integer): string;
begin
  case A1 of
    0: Result := TranslateRStr(DispelMagicRStr);
    1: Result := TranslateRStr(DispelMagicRStr) + ' I';
    2: Result := TranslateRStr(DispelMagicRStr) + ' II';
    3: Result := TranslateRStr(DispelMagicRStr) + ' III';
  end;
end;

function TDispelMagicAbility.ExpandName(A1: TAbilityOwner): string;
begin
  Result := GetLevelName(GetLevel(A1) + 1);
end;
function TDispelMagicAbility.GetName(A1: TAbilityOwner): string;
begin
  Result := GetLevelName(GetLevel(A1));
  if (A1 <> nil) and not GetEnabled(A1) then
    Result := Result + ' (' + LowerCase(TranslateRStr(UsedRStr)) + ')';
end;

function TDispelMagicAbility.ExpandCost(A1: TAbilityOwner): Integer;
begin
  Result := 5;
end;

function TDispelMagicAbility.CanExpand(A1: TAbilityOwner): Boolean;
begin
  if (A1.GetAbilitySelectionTypes * FSelectionTypes = []) or (GetLevel(A1) >= 3) then
  begin
    Result := False;
    Exit;
  end;
  Result := True;
end;

function TDispelMagicAbility.GetSkillPoints(A1: TAbilityOwner): Integer;
begin
  Result := GetLevel(A1) * 5;
end;
function TDispelMagicAbility.Expand(A1: TAbilityOwner): Boolean;
var
  Data: TDispelMagicAbilityData;
begin
  Result := False;
  Data := TDispelMagicAbilityData(A1.GetAbilityData(FAbilityID));
  if Data = nil then
  begin
    Data := TDispelMagicAbilityData.Create(nil);
    Data.FLevel := 1;
    Data.FEnabled := True;
    SetAb(A1, FAbilityID, 1);
    A1.AddAbilityData(Data);
    Result := True;
  end
  else if Data.FLevel <> 3 then
  begin
    Result := True;
    Inc(Data.FLevel);
    { Original skips level one when upgrading data created by SetEnabled. }
    if Data.FLevel = 1 then Data.FLevel := 2;
  end;
end;
function TDispelMagicAbility.Remove(A1: TAbilityOwner): Boolean;
var
  Data: TDispelMagicAbilityData;
begin
  Result := True;
  Data := TDispelMagicAbilityData(A1.GetAbilityData(FAbilityID));
  if Data <> nil then
  begin
    if Data.FLevel = 1 then
    begin
      SetAb(A1, FAbilityID, 0);
      A1.RemoveAbilityData(Data);
    end
    else
      Dec(Data.FLevel);
  end
  else
  begin
    SetAb(A1, FAbilityID, 0);
    Result := False;
  end;
end;
function TDispelMagicAbility.CanTouchUnit(A1, A2: TAbstractUnit): Boolean;
begin
  Result := inherited CanTouchUnit(A1, A2);
  if Result then Result := A2.CanDispelEnchantment(A1.FPlayer);
end;

function TDispelMagicAbility.CanTouch(A1, A2: TCombatObject): Boolean;
begin
  Result := inherited CanTouch(A1, A2);
  if Result then
    Result := (A1 is TCombatUnit) and (A2 is TCombatUnit) and
      TCombatUnit(A2).FUnit.CanDispelEnchantment(A1.GetPlayer);
end;

function TDispelMagicAbility.GetDamageValue(A1, A2: TAbstractUnit): Integer;
begin
  { Original evaluates dispelling with the healing hit-point formula. }
  if not (dtNone in A2.GetImmunityTypes) then
  begin
    Result := A2.GetHits - A2.GetHitPoints;
    if Result > 5 then Result := 5;
    Result := Result * 100;
    Exit;
  end;
  Result := 0;
end;
procedure TDispelMagicAbility.GetDamageValueEx(A1, A2: TAbstractUnit; A3: TWallSituation; var A4: TAbilityDamageValues);
begin
  { Original evaluates dispelling with the healing hit-point formula. }
  if (A3 = wsNone) and not (dtNone in A2.GetImmunityTypes) then
  begin
    A4.SourceCost := A2.GetHits - A2.GetHitPoints;
    if A4.SourceCost > 5 then A4.SourceCost := 5;
    A4.SourceDamage := A4.SourceCost * 100;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [dtNone];
  end
  else
  begin
    A4.SourceDamage := 0;
    A4.SourceCost := 0;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [];
  end;
end;
procedure TDispelMagicAbility.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
begin
  if (A3 = wsNone) and CanTouch(A1, A2) then
  begin
    { Original assigns zero benefit, so its prefetch loop emits no commands. }
    A4.SourceCost := 0;
    A4.SourceDamage := A4.SourceCost * 100;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [dtNone];
  end
  else
  begin
    A4.SourceDamage := 0;
    A4.SourceCost := 0;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [];
  end;
end;

function TDispelMagicAbility.fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean;
var
  Target: TCombatObject;
  Action: TDispelMagicAbilityCA;
begin
  Target := A2.FTarget;
  fcValidateMoveOutsideWall(A1, Target);
  Action := TDispelMagicAbilityCA.Create(nil);
  Action.Generate(A1, Target, GetDispelMana(TCombatUnit(A1).FUnit));
  A1.FCombat.ExecuteCombatAction(Action);
  Action.Release;
  Result := True;
end;

procedure TDispelMagicAbility.fcPrefetchCombatCommands(A1: TFastCombatCommandList);
var
  I: Integer;
  Target: TCombatObject;
  Command: TFastCombatCommand;
  Values: TAbilityDamageValues;
begin
  for I := 0 to A1.FSourceSide.GetCount - 1 do
  begin
    Target := A1.FSourceSide.GetObjects(I);
    if Target.GetEnabled and CanTouch(A1.FSource, Target) then
    begin
      fcGetDamageValueEx(A1.FSource, Target, wsNone, Values);
      if Values.SourceDamage <> 0 then
      begin
        Command := TFastCombatCommand.Create(FAbilityID);
        Command.FTarget := Target;
        Command.FSourceDV := Values.SourceDamage;
        Command.FTargetDV := 0;
        Command.FExpectedDV := DVtoDEV(Values.SourceDamage, 0, A1.FSource, Target);
        Command.FMoveCost := 0;
        A1.Add(Command);
      end;
    end;
  end;
end;
function TDispelMagicAbility.CreateCA(A1, A2: TCombatObject): TDispelMagicAbilityCA;
var
  Successful: Boolean;
begin
  Result := TDispelMagicAbilityCA.Create(nil);
  Result.Generate(A1, A2, GetDispelMana(TCombatUnit(A1).FUnit));
  if A1.GetSide = A2.GetSide then Successful := True
  else Successful := CombatTouchRole(TCombatUnit(A1), A2);
  if not Successful then Result.FEnchantmentIDs.Clear;
end;

function TDispelMagicAbility.Activate(A1: TAbilityOwner; var A2: string): Boolean;
var
  Info: TUnitSelectorAAI;
  Selector: TDispelMagicAbilityUnitSelector;
begin
  if CanActivate(A1, A2) then
  begin
    Info := TUnitSelectorAAI.Create(nil);
    Info.FAbilityID := FAbilityID;
    if A1 is TAbstractUnit then Info.FUnitID := TAbstractUnit(A1).FUnitID
    else Info.FUnitID := 0;
    Selector := TDispelMagicAbilityUnitSelector.Create;
    Selector.FCaption := Format(TranslateRStr(SelectUnitForXRStr), [TranslateRStr(DispelMagicRStr)]);
    Selector.Setup(A1, TUnitList(A1.Owner));
    Info.SetUnitSelector(Selector);
    Selector.Release;
    AoWHSMap.FOnActivateAbility.TriggerNotifyEvents(Info);
    Info.Release;
    Result := True;
  end
  else Result := False;
end;
class function TDispelMagicAbilityTE.ClassID: Integer;
begin
  Result := $202F3;
end;

procedure TDispelMagicAbilityTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FSourceID, 25);
  Stream.rwByte(FSourcePlayer, 26);
  Stream.rwInteger(FTargetID, 27);
  Stream.rwByte(FTargetPlayer, 28);
end;

function TDispelMagicAbilityTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
var
  Count, Mana: Integer;
  Ability: TDispelMagicAbility;
  Enchantments: TEnchantmentList;
  Source, Target: TAbstractUnit;
  X, Y, L: Shortint;
  Success: Boolean;
  I, Chance: Integer;
  Anim: TImageSequenceAnimation;
begin
  inherited Execute(TE);
  Enchantments := TEnchantmentList.Create(nil);
  Source := AoWHSMap.FUnitControl.FindUnit(FSourceID);
  Target := AoWHSMap.FUnitControl.FindUnit(FTargetID);
  Ability := TDispelMagicAbility(AoWHSSet.FAbilityControl.GetAbility(60));
  Success := (Source <> nil) and (Byte(Source.FPlayer) = FSourcePlayer) and
    (Target <> nil) and (Byte(Target.FPlayer) = FTargetPlayer);
  Success := Success and Ability.GetEnabled(Source);
  if Success then
  begin
    Target.ListEnchantments(Enchantments);
    Success := Enchantments.GetCount > 0;
  end;
  if Success then
  begin
    Count := 0;
    Mana := TDispelMagicAbility(AoWHSSet.FAbilityControl.GetAbility(60)).GetDispelMana(Source);
    for I := Enchantments.GetCount - 1 downto 0 do
    begin
      Chance := Enchantments.GetEnchantments(I).DispelChance(Mana);
      if Chance > AoWHSMap.Random(100) then
      begin
        Inc(Count);
        Enchantments.GetEnchantments(I).Dispel;
      end;
    end;
    if Source.FPlayer = AoWHSMap.FSeatedPlayer then
      if Count > 0 then
        AoWHSMap.ShowMessage(Format(TranslateRStr(XSpellsSuccessfullyDispelledRStr), [IntToStr(Count)]))
      else
        AoWHSMap.ShowMessage(TranslateRStr(DispelMagicFailedRStr));
    Ability.SetEnabled(Source, False);
    Target.GetLocation(X, Y, L);
    AoWHSMap.ValidateObservation(FSourcePlayer, X, Y, L, 0);
    if AoWHSMap.Visible(X, Y, L, 0) then
    begin
      Anim := TImageSequenceAnimation.Create(nil);
      Anim.SetImageSequence(Ability.FImageSequences.GetImageSequence(0));
      AoWHSMap.PlaceHX(Anim, X, Y, L);
    end;
    if (Byte(AoWHSMap.FSeatedPlayer) = FSourcePlayer) or AoWHSMap.Watching(X, Y, L, 0) then
      Ability.FSFXLibrary.Play(0);
    Result := erDone;
  end
  else Result := erDoneHalt;
  Enchantments.Free;
end;

function TDispelMagicAbilityUnitSelector.CanSelectUnit(A1: TUnit): Boolean;
begin
  Result := A1.CanDispelEnchantment(FPlayer);
end;

function TDispelMagicAbilityUnitSelector.Select: Boolean;
var
  Source, Target: TAbstractUnit;
  Error: string;
  I: Integer;
  Event: TDispelMagicAbilityTE;
begin
  Source := AoWHSMap.FUnitControl.FindUnit(FSourceUnitID);
  if CanSelect(Error) and not AoWHSMap.FPlayers.GetPlayers(Source.FPlayer).GetBusy then
  begin
    I := 0;
    Target := nil;
    while (Target = nil) and (I <> FUnits.GetCount) do
    begin
      if (FSelection and (1 shl I)) <> 0 then Target := FUnits.GetUnit(I);
      Inc(I);
    end;
    if Target <> nil then
    begin
      Event := TDispelMagicAbilityTE.Create(nil);
      Event.FSourceID := Source.FUnitID;
      Event.FSourcePlayer := Source.FPlayer;
      Event.FTargetID := Target.FUnitID;
      Event.FTargetPlayer := Target.FPlayer;
      AoWHSMap.FTokenManager.GetTokenControl(Source.FPlayer).AddEvent(Event);
      Event.Release;
      Result := True;
    end
    else Result := False;
  end
  else Result := False;
end;

constructor TSpellCastingAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityID := 52;
  FAbilityName := TranslateRStr(SpellCastingRStr);
  FAbilityType := atEnhancement;
  FMaxLevel := 5;
  FLevelCosts[1] := 20;
  FLevelCosts[2] := 20;
  FLevelCosts[3] := 20;
  FLevelCosts[4] := 20;
  FLevelCosts[5] := 20;
end;

function TSpellCastingAbility.GetLevelName(A1: Integer): string;
begin
  case A1 of
    0: Result := TranslateRStr(SpellCastingRStr);
    1: Result := TranslateRStr(SpellCastingRStr) + ' I';
    2: Result := TranslateRStr(SpellCastingRStr) + ' II';
    3: Result := TranslateRStr(SpellCastingRStr) + ' III';
    4: Result := TranslateRStr(SpellCastingRStr) + ' IV';
    5: Result := TranslateRStr(SpellCastingRStr) + ' V';
  end;
end;

function TSpellCastingAbility.GetControlType: TAbilityControlType;
begin Result := [acAction, acCombatAction]; end;

function TSpellCastingAbility.Expand(A1: TAbilityOwner): Boolean;
begin
  Result := inherited Expand(A1);
  if Result then
    if (A1 is TAbstractUnit) and (AoWHSMap <> nil) then
      AoWHSMap.FPlayers.GetPlayers(TAbstractUnit(A1).FPlayer).FMagicControl.Update;
end;

function TSpellCastingAbility.Remove(A1: TAbilityOwner): Boolean;
begin
  Result := inherited Remove(A1);
  if Result then
    if (A1 is TAbstractUnit) and (AoWHSMap <> nil) then
      AoWHSMap.FPlayers.GetPlayers(TAbstractUnit(A1).FPlayer).FMagicControl.Update;
end;

function TSpellCastingAbility.CanActivate(A1: TAbilityOwner; var A2: string): Boolean;
begin
  if A1 is THero then Result := True
  else Result := False;
end;

function TSpellCastingAbility.fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean;
begin
  Result := AoWHSSet.FSpellControl.GetSpell(TSpellCC(A2).FSpellID).fcExecuteCombatCommand(A1, A2);
end;

function TSpellCastingAbility.CanCastBreachWallSpell(AUnit: TAbstractUnit): Boolean;
var
  I: Integer;
  Spell: TSpell;
  Info: TSpellCombatInfo;
  Error: string;
  Magic: TPlayerMagicControl;
begin
  if AUnit is THero then
  begin
    Magic := AoWHSMap.FPlayers.GetPlayers(AUnit.FPlayer).FMagicControl;
    Result := Magic.GetCheatEnabled;
    I := Magic.FSpells.Count;
    while not Result and (I <> 0) do
    begin
      Dec(I);
      Spell := AoWHSSet.FSpellControl.GetSpell(Magic.FSpells[I]);
      if (Spell <> nil) and (Spell.FSpellType = stCombat) then
      begin
        Spell.GetCombatInfo(AUnit, Info);
        Result := (dtWall in Info.DamageTypes) and
          THero(AUnit).CanCastCombatSpell(Magic.FSpells[I], Error);
      end;
    end;
  end
  else Result := False;
end;

function TSpellCastingAbility.AICanCastCombatSpell(A1: TCombatUnit): Boolean;
var
  Hero: THero;
  SourceStrength, TargetStrength: Integer;
  Ratio: Single;
begin
  Hero := THero(A1.FUnit);
  Result := (AoWHSMap.FPlayers.GetPlayers(Hero.FPlayer).FPlayerType <> ptHuman) or
    (Hero.FCastingSpellID = 0);
  if Result then
  begin
    SourceStrength := A1.FCombat.FSides[A1.GetSide].FStrength;
    if SourceStrength <= 0 then SourceStrength := 0;
    TargetStrength := A1.FCombat.FSides[A1.GetOpponentSide].FStrength;
    if TargetStrength <= 0 then TargetStrength := 0;
    { Original divides by zero when the opponent strength is zero. }
    Ratio := SourceStrength / TargetStrength;
    if ((Ratio >= 1.5) or (Hero.FCastingSpellID <> 0)) and
      (Ratio >= 1) and (A1.GetHitPoints * Ratio >= 7) then
      Result := False
    else Result := True;
  end;
end;

procedure TSpellCastingAbility.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
var
  I: Integer;
  Spell: TSpell;
  Source: TAbstractUnit;
  Magic: TPlayerMagicControl;
  Values: TAbilityDamageValues;
begin
  FillChar(A4, 20, 0);
  if A1 is TCombatUnit then
  begin
    Magic := AoWHSMap.FPlayers.GetPlayers(A1.GetPlayer).FMagicControl;
    Source := TCombatUnit(A1).FUnit;
    for I := Magic.FSpells.Count - 1 downto 0 do
    begin
      Spell := AoWHSSet.FSpellControl.GetSpell(Magic.FSpells[I]);
      if (Spell <> nil) and (sctCombat in Spell.FSpellControlTypes) and
        (Source.GetCastingPointsMax >= Spell.FBaseManaCost) then
      begin
        Spell.fcGetDamageValueEx(A1, A2, A3, Values);
        if A4.SourceDamage < Values.SourceDamage then A4 := Values;
      end;
    end;
  end;
end;

procedure TSpellCastingAbility.tcGetDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues);
var
  I: Integer;
  Spell: TSpell;
  Source: TAbstractUnit;
  Magic: TPlayerMagicControl;
  Values: TAbilityDamageValues;
begin
  FillChar(A3, 20, 0);
  if A1 is TCombatUnit then
  begin
    Magic := AoWHSMap.FPlayers.GetPlayers(A1.GetPlayer).FMagicControl;
    Source := TCombatUnit(A1).FUnit;
    for I := Magic.FSpells.Count - 1 downto 0 do
    begin
      Spell := AoWHSSet.FSpellControl.GetSpell(Magic.FSpells[I]);
      if (Spell <> nil) and (sctCombat in Spell.FSpellControlTypes) and
        (Source.GetCastingPoints >= Spell.FBaseManaCost) then
      begin
        Spell.fcGetDamageValueEx(A1, A2, wsNone, Values);
        if A3.SourceDamage < Values.SourceDamage then A3 := Values;
      end;
    end;
  end;
end;

procedure TSpellCastingAbility.fcPrefetchCombatCommands(A1: TFastCombatCommandList);
var
  Combat: TFastCombat;
  Source: TCombatObject;
  Error: string;
  Magic: TPlayerMagicControl;
  I: Integer;
  Spell: TSpell;
begin
  Combat := A1.FCombat;
  Source := A1.FSource;
  if Source is TCombatUnit then
    if (AoWHSMap.FPlayers.GetPlayers(Combat.FCombatData.FPlayers.GetPlayers(Source.FCombatPlayer).FPlayer).FPlayerType <> ptHuman) or
      (THero(TCombatUnit(Source).FUnit).FCastingSpellID = 0) then
      if (Combat.FSides[Source.GetSide].FStrength < Combat.FSides[Source.GetOpponentSide].FStrength * 2) or
        (Source.GetHitPoints < 10) or
        ((Combat.FCombatData.FWallType <> 0) and not Combat.FCombatData.FWallBreached and CanCastBreachWallSpell(TCombatUnit(Source).FUnit)) then
      begin
        Magic := AoWHSMap.FPlayers.GetPlayers(A1.FSource.GetPlayer).FMagicControl;
        if not Magic.GetCheatEnabled then
        begin
          for I := Magic.FSpells.Count - 1 downto 0 do
          begin
            Spell := AoWHSSet.FSpellControl.GetSpell(Magic.FSpells[I]);
            if (Spell <> nil) and (sctCombat in Spell.FSpellControlTypes) then
              if TCombatUnit(A1.FSource).FUnit is THero then
                if THero(TCombatUnit(A1.FSource).FUnit).CanCastSpellInstantly(Spell.FSpellID, Spell.FBaseManaCost, Error) then
                  Spell.fcPrefetchCombatCommands(A1);
          end;
        end
        else
          for I := 0 to AoWHSSet.FSpellControl.GetCount - 1 do
          begin
            Spell := AoWHSSet.FSpellControl.GetSpell(I);
            if (Spell <> nil) and (sctCombat in Spell.FSpellControlTypes) then
              Spell.fcPrefetchCombatCommands(A1);
          end;
      end;
end;

class function TRangedAttackCA.ClassID: Integer;
begin
  Result := $202A9;
end;

procedure TRangedAttackCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(FAbilityID, 4, 20);
end;

procedure TRangedAttackCA.ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc);
begin
  inherited ShowObject(A1, A2, A3, A4, A5, A6, A7);
  if (A2.FID = FTargetID) and (A1.FTime <> 0) then
    AoWHSSet.FAbilityControl.GetAbility(FAbilityID).FImageSequences.Show(40,
      A5 + 32, A6 + 32, A1.FTime, A7);
end;

function TRangedAttackCA.GetName: string;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(FAbilityID).GetName(nil);
end;

function TRangedAttackCA.Play(A1: TCombatViewer): Boolean;
begin
  if A1.FTime = 1 then
    AoWHSSet.FAbilityControl.GetAbility(FAbilityID).FSFXLibrary.Play(0);
  Result := inherited Play(A1);
end;

constructor TRangedAttackAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSelectionTypes := [astUnit, astUseItem];
  FAbilityType := atCombat;
end;

function TRangedAttackAbility.GetControlType: TAbilityControlType;
begin Result := [acCombatAction]; end;

function TRangedAttackAbility.GetRangeRA(A1: TAbilityOwner): TCombatRange;
begin
  Result := FRangeRA;
end;

function TRangedAttackAbility.GetDamageRA(A1: TAbilityOwner): Shortint;
begin
  Result := FDamageRA;
  if (A1 <> nil) and A1.GetAbEnabled(32) then
    case A1.GetAbLevel(32) of
      2: Inc(Result);
      3: Inc(Result);
      4: Inc(Result, 2);
    end;
end;

function TRangedAttackAbility.GetAttackRA(A1: TAbilityOwner): Shortint;
begin
  Result := FAttackRA;
  if (A1 <> nil) and A1.GetAbEnabled(32) then
    case A1.GetAbLevel(32) of
      1: Inc(Result);
      2: Inc(Result);
      3: Inc(Result, 2);
      4: Inc(Result, 2);
    end;
end;

function TRangedAttackAbility.GetAttackRepeatRA(A1: TAbilityOwner): Shortint;
begin
  Result := FAttackRepeatRA;
end;

function TRangedAttackAbility.GetDamageTypesRA(A1: TAbilityOwner): TDamageTypes;
begin
  Result := FDamageTypesRA.Value;
end;

function TRangedAttackAbility.GetCombatMode(A1: TAbilityOwner): TCombatMode;
begin
  Result := CombatRangeToCombatMode(GetRangeRA(A1));
end;

function TRangedAttackAbility.GetWallCombatFeatures(A1: TAbilityOwner): TWallCombatFeatures;
begin
  if dtWall in GetDamageTypesRA(A1) then Result := [wcWallBreaching, wcParticipate]
  else Result := [wcParticipate];
end;

procedure TRangedAttackAbility.GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes);
begin
  A2 := P4OffensiveStrength(GetAttackRA(A1), GetDamageRA(A1), GetAttackRepeatRA(A1));
  A3 := GetDamageTypesRA(A1);
end;

function TRangedAttackAbility.GetDamageValue(A1, A2: TAbstractUnit): Integer;
var
  Repeats: Integer;
begin
  Result := StatisticsToLimitedDV(GetAttackRA(A1), GetDamageRA(A1), GetDamageTypesRA(A1),
    A2.GetHitPoints, A2.GetDefense, A2.GetResistance, A2.GetImmunityTypes, A2.GetProtectionTypes);
  Repeats := GetAttackRepeatRA(A1);
  Result := Result * Repeats;
end;

procedure TRangedAttackAbility.GetDamageValueEx(A1, A2: TAbstractUnit; A3: TWallSituation; var A4: TAbilityDamageValues);
var
  Defense, Damage, Repeats: Integer;
begin
  Defense := A2.GetDefense;
  if A3 = wsTarget then Inc(Defense, 2);
  Damage := StatisticsToLimitedDV(GetAttackRA(A1), GetDamageRA(A1), GetDamageTypesRA(A1),
    A2.GetHitPoints, Defense, A2.GetResistance, A2.GetImmunityTypes, A2.GetProtectionTypes);
  Repeats := GetAttackRepeatRA(A1);
  Damage := Damage * Repeats;
  A4.SourceDamage := Damage;
  A4.TargetDamage := 0;
  A4.DamageTypes := GetDamageTypesRA(A1);
  { Original leaves both cost fields untouched. }
end;

procedure TRangedAttackAbility.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
var
  DamageTypes, ProtectionTypes, ImmunityTypes: TDamageTypes;
  Damage, Defense, Value, Repeats: Integer;
  Range: TCombatRange;
begin
  Range := GetRangeRA(A1.GetAbilityOwner);
  if (A3 = wsNone) or (Range in [crMedium, crLong]) or A1.GetAbilityEnabled(1) then
  begin
    ProtectionTypes := A2.GetProtectionTypes;
    ImmunityTypes := A2.GetImmunityTypes;
    DamageTypes := GetDamageTypesRA(A1.GetAbilityOwner);
    Damage := GetDamageRA(A1.GetAbilityOwner);
    Defense := A2.GetDefense;
    if A3 = wsTarget then Inc(Defense, 2);
    A4.DamageTypes := GetDamageTypesRA(A1.GetAbilityOwner);
    Value := StatisticsToLimitedDV(GetAttackRA(A1.GetAbilityOwner), Damage, DamageTypes,
      A2.GetHitPoints, Defense, A2.GetResistance, ImmunityTypes, ProtectionTypes);
    Repeats := GetAttackRepeatRA(A1.GetAbilityOwner);
    Value := Value * Repeats;
    A4.SourceDamage := Value;
    Value := StatisticsToMaxDamage(Damage, DamageTypes, ImmunityTypes, ProtectionTypes);
    Repeats := GetAttackRepeatRA(A1.GetAbilityOwner);
    Value := Value * Repeats;
    A4.SourceCost := Value;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
  end
  else
  begin
    A4.SourceDamage := 0;
    A4.SourceCost := 0;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [];
  end;
end;

procedure TRangedAttackAbility.GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo);
begin
  A2.Attack := GetAttackRA(A1);
  A2.Damage := GetDamageRA(A1);
  A2.DamageTypes := GetDamageTypesRA(A1);
  A2.RepeatCount := GetAttackRepeatRA(A1);
  A2.Kind := [cmMelee];
end;

function TRangedAttackAbility.CreateRangedAttackCA(A1, A2: TCombatObject; A3: Integer): TRangedAttackCA;
var
  Action: TRangedAttackCA;
begin
  Action := TRangedAttackCA.Create(nil);
  Action.Generate(A1, A2, GetAttackRA(A1.GetAbilityOwner) - A3,
    GetDamageRA(A1.GetAbilityOwner), GetDamageTypesRA(A1.GetAbilityOwner));
  Action.FAbilityID := FAbilityID;
  Result := Action;
end;

function TRangedAttackAbility.fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean;
var
  Target: TCombatObject;
  Penalty, I: Integer;
  Action: TRangedAttackCA;
begin
  Target := A2.FTarget;
  if TFastCombat(A1.FCombat).GetWallSituation(A1, Target) = wsTarget then Penalty := 2
  else Penalty := 0;
  if Target.GetEnabled then
  begin
    for I := GetAttackRepeatRA(A1.GetAbilityOwner) - 1 downto 0 do
    begin
      Action := CreateRangedAttackCA(A1, Target, Penalty);
      A1.FCombat.ExecuteCombatAction(Action);
      Action.Release;
    end;
    TFastCombatUnit(A1).FState := TFastCombatUnit(A1).FState + [fsVulnerable];
  end;
  Result := True;
end;

procedure TRangedAttackAbility.fcPrefetchCombatCommands(A1: TFastCombatCommandList);
var
  I: Integer;
  Target: TCombatObject;
  Values: TAbilityDamageValues;
  Command: TFastCombatCommand;
begin
  for I := 0 to A1.FTargetSide.GetCount - 1 do
  begin
    Target := A1.FTargetSide.GetObjects(I);
    if Target.GetEnabled and fcValidRoundDistance(A1.FSource, Target) then
    begin
      fcGetDamageValueEx(A1.FSource, Target, TFastCombat(A1.FSource.FCombat).GetWallSituation(A1.FSource, Target), Values);
      if Values.SourceDamage <> 0 then
      begin
        Command := TFastCombatCommand.Create(FAbilityID);
        Command.FTarget := A1.FTargetSide.GetObjects(I);
        Command.FMoveCost := 1;
        Command.FExpectedDV := DVtoDEV(Values.SourceDamage, Values.TargetDamage, A1.FSource, Target);
        A1.Add(Command);
      end;
    end;
  end;
end;

function TRangedAttackAbility.fcValidRoundDistance(A1, A2: TCombatObject): Boolean;
var
  Distance: Integer;
  Range: TCombatRange;
begin
  Distance := TFastCombat(A1.FCombat).GetRoundDistance;
  Range := GetRangeRA(A1.GetAbilityOwner);
  if Range = crLong then Inc(Distance, 4)
  else if Range = crMedium then Inc(Distance, 2)
  else if Range = crShort then Inc(Distance);
  Result := Distance >= A2.fcRoundDistance;
end;

constructor TBoltsAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSelectionTypes := [astUnit, astUseItem];
  FAbilityType := atCombat;
  FRangeRA := crMedium;
  FAttackRepeatRA := 1;
end;

constructor TBreathAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FRangeRA := crShort;
  FAttackRepeatRA := 1;
  FAttackRA := 7;
  FDamageRA := 5;
end;

procedure TBreathAbility.GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes);
begin
  A2 := P4OffensiveStrength(GetAttackRA(A1), GetDamageRA(A1), GetAttackRepeatRA(A1));
  A2 := A2 * 2;
  A3 := GetDamageTypesRA(A1);
end;

procedure TBreathAbility.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
var
  Count: Integer;
  Combat: TFastCombat;
  I: Integer;
  Target: TCombatObject;
begin
  inherited fcGetDamageValueEx(A1, A2, A3, A4);
  if A4.SourceDamage <> 0 then
  begin
    Combat := TFastCombat(A1.FCombat);
    Count := 0;
    for I := Combat.FSides[A2.GetSide].GetCount - 1 downto 0 do
    begin
      Target := Combat.FSides[A2.GetSide].GetObjects(I);
      if (Target <> A2) and Target.GetEnabled and
        (Target.FPosition shr 4 = A2.FPosition shr 4) and
        (Target.fcRoundDistance <= Combat.GetRoundDistance) and
        (FDamageTypesRA.Value - Target.GetImmunityTypes <> []) then
        Inc(Count);
    end;
    if Count <> 0 then
    begin
      if Count > 3 then Count := 3;
      Inc(A4.SourceDamage, Round(A4.SourceDamage * Count / 3));
    end;
  end;
end;

function TBreathAbility.fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean;
var
  Combat: TFastCombat;
  Targets: TList;
  Target, Other: TCombatObject;
  I, Count: Integer;
  Action: TRangedAttackCA;
begin
  Result := inherited fcExecuteCombatCommand(A1, A2);
  if Result then
  begin
    Combat := TFastCombat(A1.FCombat);
    Targets := TList.Create;
    Target := A2.FTarget;
    for I := Combat.FSides[Target.GetSide].GetCount - 1 downto 0 do
    begin
      Other := Combat.FSides[Target.GetSide].GetObjects(I);
      if (Other <> Target) and Other.GetEnabled and
        (Other.FPosition shr 4 = Target.FPosition shr 4) and
        (Other.fcRoundDistance <= Combat.GetRoundDistance) and
        (FDamageTypesRA.Value - Other.GetImmunityTypes <> []) then
        Targets.Add(Other);
    end;
    Count := AoWHSMap.Random(2) + 1;
    while (Count <> 0) and (Targets.Count <> 0) do
    begin
      Other := Targets[AoWHSMap.Random(Targets.Count)];
      Action := CreateRangedAttackCA(A1, Other, 2);
      A1.FCombat.ExecuteCombatAction(Action);
      Action.Release;
      Targets.Remove(Other);
      Dec(Count);
    end;
    Targets.Free;
  end;
end;

procedure TBreathAbility.tcGetDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues);
begin
  inherited fcGetDamageValueEx(A1, A2, wsNone, A3);
end;

constructor TFlameThrowingAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityID := 30;
  FAbilityName := TranslateRStr(FlameThrowingRStr);
  FAttackRA := 4;
  FDamageRA := 3;
  FDamageTypesRA.Value := [dtFire];
end;

procedure TFlameThrowingAbility.GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes);
begin
  A2 := P4OffensiveStrength(GetAttackRA(A1), GetDamageRA(A1), GetAttackRepeatRA(A1));
  A2 := A2 * 2;
  A3 := GetDamageTypesRA(A1);
end;

constructor TCommandAbilityData.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FCommandedUnits := TByteList.Create;
end;

destructor TCommandAbilityData.Destroy;
begin
  FCommandedUnits.Free;
  inherited Destroy;
end;

class function TCommandAbilityData.ClassID: Integer;
begin
  Result := $202AB;
end;

function TCommandAbilityData.GetAbilityID: Integer;
begin
  Result := FAbilityID;
end;

procedure TCommandAbilityData.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FAbilityID, 20);
  Stream.rwStreamProc(21, FCommandedUnits.LoadFromStream, FCommandedUnits.SaveToStream);
end;

function TCommandAbilityData.CommandingTargetPriority(Combat: TCombat): Integer;
var
  I: Integer;
  Target: TCombatObject;
begin
  Result := 0;
  for I := FCommandedUnits.Count - 1 downto 0 do
  begin
    Target := Combat.FCombatData.FindID(FCommandedUnits.List^[I]);
    if Target <> nil then Inc(Result, Target.GetTargetPriority);
  end;
end;

function TCommandAbilityData.CommandingTargetStrength(Combat: TCombat): Integer;
var
  I: Integer;
  Target: TCombatObject;
begin
  Result := 0;
  for I := FCommandedUnits.Count - 1 downto 0 do
  begin
    Target := Combat.FCombatData.FindID(FCommandedUnits.List^[I]);
    if Target <> nil then Inc(Result, Target.GetTargetStrength);
  end;
end;

class function TCommandedAbilityData.ClassID: Integer;
begin
  Result := $202AD;
end;

function TCommandedAbilityData.GetAbilityID: Integer;
begin
  Result := FAbilityID;
end;

procedure TCommandedAbilityData.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FAbilityID, 20);
  Stream.rwInteger(FCommandAbilityID, 21);
  Stream.rwByte(FSourceID, 22);
  Stream.rwByte(FOriginalCombatPlayer, 23);
end;

constructor TCommandedAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityType := atHandicap;
  FSelectionTypes := [];
end;

function TCommandedAbility.AbilityDataClass: TEObjectClass;
begin
  Result := P4CommandedDataClass;
end;

function TCommandedAbility.Remove(A1: TAbilityOwner): Boolean;
begin
  Result := inherited Remove(A1);
  if Result then A1.RemoveAbilityDataID(FAbilityID);
end;

procedure TCommandedAbility.CombatDone(A1: TCombatObject);
begin
  Remove(A1.GetAbilityOwner);
end;

procedure TCommandedAbility.CombatObjectDestroyed(A1: TCombatObject);
var
  Data: TCommandedAbilityData;
begin
  Data := TCommandedAbilityData(A1.GetAbilityOwner.GetAbilityData(FAbilityID));
  if Data <> nil then
    TCommandAbility(AoWHSSet.FAbilityControl.GetAbility(Data.FCommandAbilityID)).Uncommand(TCombatUnit(A1));
end;

class function TCommandCA.ClassID: Integer;
begin
  Result := $202B3;
end;

procedure TCommandCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FAbilityID, 20);
  Stream.rwBool(FSuccessful, 21);
end;

procedure TCommandCA.Initialize(SourceID, TargetID: Byte; Successful: Boolean);
begin
  FSourceID := SourceID;
  FTargetID := TargetID;
  FSuccessful := Successful;
end;

procedure TCommandCA.ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc);
begin
  inherited ShowObject(A1, A2, A3, A4, A5, A6, A7);
  if A2.FID = FSourceID then
    AoWHSSet.FAbilityControl.GetAbility(FAbilityID).FImageSequences.Show(0,
      A5 + 32, A6 + 32, A1.FTime, A7);
end;

procedure TCommandCA.Execute(A1: TCombat);
var
  Source, Target: TCombatUnit;
  I: Integer;
begin
  if FSuccessful then
  begin
    Source := TCombatUnit(A1.FCombatData.FindID(FSourceID));
    Target := TCombatUnit(A1.FCombatData.FindID(FTargetID));
    Source.SetExperience(Source.GetExperience + Target.GetLevel);
    for I := 0 to 2 do
      TCommandAbility(AoWHSSet.FAbilityControl.GetAbility(CommandAbilityIDs[I])).ResetCommandedUnits(Target);
    for I := 0 to 2 do
      TCommandAbility(AoWHSSet.FAbilityControl.GetAbility(CommandAbilityIDs[I])).Uncommand(Target);
    if Source.GetSide <> Target.GetSide then
      TCommandAbility(AoWHSSet.FAbilityControl.GetAbility(FAbilityID)).Command(Source, Target);
  end;
end;

function TCommandCA.Play(A1: TCombatViewer): Boolean;
begin
  if A1.FTime = 0 then
    AoWHSSet.FAbilityControl.GetAbility(FAbilityID).FSFXLibrary.Play(0);
  if A1.FDelay = A1.FTime then Execute(A1.FCombat);
  Result := A1.FDelay * 2 > A1.FTime;
end;

constructor TCommandAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSelectionTypes := [astUnit, astUseItem];
end;

function TCommandAbility.AbilityDataClass: TEObjectClass;
begin
  Result := P4CommandDataClass;
end;

function TCommandAbility.Remove(A1: TAbilityOwner): Boolean;
begin
  Result := inherited Remove(A1);
  if Result then A1.RemoveAbilityDataID(FAbilityID);
end;

procedure TCommandAbility.CombatDone(A1: TCombatObject);
begin
  A1.GetAbilityOwner.RemoveAbilityDataID(FAbilityID);
end;

procedure TCommandAbility.CombatObjectDestroyed(A1: TCombatObject);
begin
  ResetCommandedUnits(TCombatUnit(A1));
end;

procedure TCommandAbility.Command(Source, Target: TCombatUnit);
var
  TargetData: TCommandedAbilityData;
  SourceData: TCommandAbilityData;
  DataClass: TEObjectClass;
begin
  Uncommand(Target);
  DataClass := AoWHSSet.FAbilityControl.GetAbility(FCommandedAbilityID).AbilityDataClass;
  TargetData := TCommandedAbilityData(DataClass.Create(nil));
  TargetData.FAbilityID := FCommandedAbilityID;
  TargetData.FCommandAbilityID := FAbilityID;
  TargetData.FSourceID := Source.FID;
  TargetData.FOriginalCombatPlayer := Target.FCombatPlayer;
  SetAb(Target.FUnit, FCommandedAbilityID, 1);
  Target.FUnit.AddAbilityData(TargetData);
  Target.SetCombatPlayer(Source.FCombatPlayer);
  SourceData := TCommandAbilityData(Source.FUnit.GetAbilityData(FAbilityID));
  if SourceData = nil then
  begin
    SourceData := TCommandAbilityData.Create(nil);
    SourceData.FAbilityID := FAbilityID;
    Source.FUnit.AddAbilityData(SourceData);
  end;
  SourceData.FCommandedUnits.Add(Target.FID);
end;

procedure TCommandAbility.Uncommand(A1: TCombatUnit);
var
  UnitOwner: TAbstractUnit;
  Data: TCommandedAbilityData;
  Source: TCombatUnit;
  SourceData: TCommandAbilityData;
begin
  UnitOwner := A1.FUnit;
  if UnitOwner.GetAbilityEnabled(FCommandedAbilityID) then
  begin
    Data := TCommandedAbilityData(UnitOwner.GetAbilityData(FCommandedAbilityID));
    { Original reads Data before checking it for nil. }
    Source := TCombatUnit(A1.FCombat.FCombatData.FindID(Data.FSourceID));
    if Data <> nil then A1.SetCombatPlayer(Data.FOriginalCombatPlayer);
    AoWHSSet.FAbilityControl.GetAbility(FCommandedAbilityID).Remove(A1.FUnit);
    if Source <> nil then
    begin
      SourceData := TCommandAbilityData(Source.FUnit.GetAbilityData(FAbilityID));
      if SourceData <> nil then SourceData.FCommandedUnits.Remove(A1.FID);
    end;
  end;
end;

procedure TCommandAbility.ResetCommandedUnits(A1: TCombatUnit);
var
  UnitOwner: TAbstractUnit;
  Data: TCommandAbilityData;
  I: Integer;
  Target: TCombatUnit;
begin
  UnitOwner := A1.FUnit;
  if UnitOwner.GetAbilityEnabled(FAbilityID) then
  begin
    Data := TCommandAbilityData(UnitOwner.GetAbilityData(FAbilityID));
    if Data <> nil then
      for I := Data.FCommandedUnits.Count - 1 downto 0 do
      begin
        Target := TCombatUnit(A1.FCombat.FCombatData.FindID(Data.FCommandedUnits[I]));
        if Target <> nil then Uncommand(Target);
      end;
  end;
end;

function TCommandAbility.CanTouch(A1, A2: TCombatObject): Boolean;
begin
  if inherited CanTouch(A1, A2) then
    Result := (A1 is TCombatUnit) and (A2 is TCombatUnit) and
      (TCombatUnit(A2).FUnit.GetUnitType <> utMachine) and
      not A2.GetAbilityEnabled(107)
  else Result := False;
end;

function TCommandAbility.CanTouchUnit(A1, A2: TAbstractUnit): Boolean;
begin
  if inherited CanTouchUnit(A1, A2) then
    Result := A2.GetUnitType <> utMachine
  else Result := False;
end;

function TCommandAbility.GetAbilityType: TAbilityType;
begin
  Result := atCombat;
end;

function TCommandAbility.GetDamageValue(A1, A2: TAbstractUnit): Integer;
var
  Probability: Single;
begin
  if CanTouchUnit(A1, A2) then
  begin
    Probability := TouchRoleProbability(A1, A2);
    Result := Round(A2.GetHitPoints * 200 * Probability);
  end
  else Result := 0;
end;

procedure TCommandAbility.GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes);
begin
  if A1 <> nil then
  begin
    A2 := Round(GetTouchAttack(GetLevel(A1)) * (TAbstractUnit(A1).GetAttack * 5) * 0.1);
    A3 := [dtNone];
  end;
end;

procedure TCommandAbility.GetDamageValueEx(A1, A2: TAbstractUnit; A3: TWallSituation; var A4: TAbilityDamageValues);
var
  Probability: Single;
begin
  if (A3 = wsNone) and
    (not A2.GetAbilityEnabled(1) or A1.GetAbilityEnabled(1)) and
    (A2.GetUnitType <> utMachine) then
  begin
    Probability := TouchRoleProbability(A1, A2);
    A4.SourceDamage := Round(A2.GetHitPoints * 200 * Probability);
    A4.SourceCost := A2.GetHitPoints * 2;
    A4.TargetDamage := Round(P4UnitStrikeDV(A2, A1) * (1 - Probability));
    A4.TargetCost := A2.GetDamage;
    { Original leaves DamageTypes unchanged on this path. }
  end
  else
  begin
    A4.SourceDamage := 0;
    A4.SourceCost := 0;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [];
  end;
end;

procedure TCommandAbility.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
var
  Probability: Single;
begin
  if CanTouch(A1, A2) and not (TCombatUnit(A2).FUnit is TLeader) then
  begin
    Probability := CombatTouchRoleProbability(TCombatUnit(A1), A2);
    A4.SourceDamage := Round(A2.GetHitPoints * 200 * Probability);
    A4.SourceCost := A2.GetHitPoints * 2;
    A4.TargetDamage := Round(StrikeDV(A2, A1) * (1 - Probability));
    A4.TargetCost := A2.GetDamage;
    { Original leaves DamageTypes unchanged on this path. }
  end
  else
  begin
    A4.SourceDamage := 0;
    A4.SourceCost := 0;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [];
  end;
end;

function TCommandAbility.CreateCommandCA(Source, Target: TCombatUnit): TCommandCA;
begin
  Result := TCommandCA.Create(nil);
  Result.Initialize(Source.FID, Target.FID,
    not (Target.FUnit is TLeader) and CombatTouchRole(Source, Target));
  Result.FAbilityID := FAbilityID;
end;

function TCommandAbility.fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean;
var
  Target: TCombatObject;
  Action: TCommandCA;
  Strike: TStrikeCA;
begin
  Target := A2.FTarget;
  fcValidateMoveOutsideWall(A1, Target);
  Action := CreateCommandCA(TCombatUnit(A1), TCombatUnit(Target));
  A1.FCombat.ExecuteCombatAction(Action);
  if not Action.FSuccessful then
  begin
    Strike := AoWE.CreateStrikeCA(Target, A1, True);
    if Strike <> nil then
    begin
      A1.FCombat.ExecuteCombatAction(Strike);
      Strike.Release;
    end;
  end;
  Action.Release;
  Result := True;
end;

procedure TCommandAbility.fcPrefetchCombatCommands(A1: TFastCombatCommandList);
var
  Distance, I: Integer;
  Target: TCombatObject;
  Values: TAbilityDamageValues;
  Command: TFastCombatCommand;
begin
  Distance := A1.FCombat.GetRoundDistance;
  if A1.FSource.GetMoves >= 32 then Inc(Distance, 2);
  for I := 0 to A1.FTargetSide.GetCount - 1 do
  begin
    Target := A1.FTargetSide.GetObjects(I);
    if Target.GetEnabled and (Target.fcRoundDistance <= Distance) and
      CanTouch(A1.FSource, Target) then
    begin
      fcGetDamageValueEx(A1.FSource, Target, wsNone, Values);
      if Values.SourceDamage <> 0 then
      begin
        Command := TFastCombatCommand.Create(FAbilityID);
        Command.FTarget := A1.FTargetSide.GetObjects(I);
        Command.FExpectedDV := DVtoDEV(Values.SourceDamage, Values.TargetDamage, A1.FSource, Target);
        Command.FMoveCost := 0;
        A1.Add(Command);
      end;
    end;
  end;
end;

constructor TDominatedAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityID := 150;
  FAbilityName := TranslateRStr(DominatedRStr);
end;

constructor TDominateAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityID := 28;
  FAbilityName := TranslateRStr(DominateRStr);
  FCommandedAbilityID := 150;
  FSelectionTypes := [astUnit];
end;

function TDominateAbility.GetTouchAttack(A1: Integer): Shortint;
begin
  Result := 6;
end;

constructor TCharmedAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityID := 149;
  FAbilityName := TranslateRStr(CharmedRStr);
end;

constructor TCharmAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityID := 148;
  FAbilityName := TranslateRStr(CharmRStr);
  FCommandedAbilityID := 149;
end;

function TCharmAbility.GetTouchAttack(A1: Integer): Shortint;
begin
  Result := 5;
end;

function TCharmAbility.CanTouchUnit(A1, A2: TAbstractUnit): Boolean;
begin
  Result := inherited CanTouchUnit(A1, A2);
  if Result then Result := (A2.GetUnitType = utHumanoid) and (Word(A2.GetRace) <> 11) and not A2.GetAbilityEnabled(129);
end;

function TCharmAbility.CanTouch(A1, A2: TCombatObject): Boolean;
var
  Target: TCombatUnit;
begin
  Result := inherited CanTouch(A1, A2);
  if Result then
  begin
    Target := TCombatUnit(A2);
    Result := (Target.FUnit.GetUnitType = utHumanoid) and (Word(Target.FUnit.GetRace) <> 11) and not Target.FUnit.GetAbilityEnabled(129);
  end;
end;

constructor TSeducedAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityID := 48;
  FAbilityName := TranslateRStr(SeducedRStr);
end;

constructor TSeduceAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityID := 29;
  FAbilityName := TranslateRStr(SeduceRStr);
  FCommandedAbilityID := 48;
  FSelectionTypes := [astUnit];
end;

function TSeduceAbility.GetTouchAttack(A1: Integer): Shortint;
begin
  Result := 4;
end;

function TSeduceAbility.CanTouchUnit(A1, A2: TAbstractUnit): Boolean;
begin
  Result := inherited CanTouchUnit(A1, A2);
  if Result then Result := (A2.GetGender = ugMale) and (A2.GetUnitType = utHumanoid);
end;

function TSeduceAbility.CanTouch(A1, A2: TCombatObject): Boolean;
var
  Target: TCombatUnit;
begin
  Result := inherited CanTouch(A1, A2);
  if Result then
  begin
    Target := TCombatUnit(A2);
    Result := (Target.FUnit.GetGender = ugMale) and (Target.FUnit.GetUnitType = utHumanoid);
  end;
end;

function TRebuildConstructionControl.GetStructure(AUnit: TAbstractUnit): TStructure;
var
  X, Y, L: Shortint;
begin
  AUnit.GetLocation(X, Y, L);
  Result := TStructure(AoWHSMap.MapContainer.GetField(X, Y, L).FindNoneTransparentHS(TStructure));
  if Result <> nil then
    if not Result.GetRazed or Result.GetBuilding then Result := nil;
end;

function TRebuildConstructionControl.ID: Integer;
begin
  Result := 1;
end;

procedure TRebuildConstructionControl.GetInfo(AUnit: TAbstractUnit; var Text: string; var Gold, Days: Integer);
var
  Structure: TStructure;
begin
  Structure := GetStructure(AUnit);
  if Structure <> nil then
  begin
    Text := Format(TranslateRStr(P4RebuildXRStr), [Structure.EditName]);
    Structure.GetRebuildInfo(Gold, Days);
  end
  else
  begin
    Text := Format(TranslateRStr(P4RebuildXRStr), [TranslateRStr(P4StructureRStr)]);
    Gold := 0;
    Days := 0;
  end;
end;

function TRebuildConstructionControl.CanConstruct(A1: TAbstractUnit; var A2: string): Boolean;
begin
  if GetStructure(A1) <> nil then Result := inherited CanConstruct(A1, A2)
  else
  begin
    A2 := TranslateRStr(P4NoRazedStructuresRStr);
    Result := False;
  end;
end;

function TRebuildConstructionControl.Construct(AUnit: TAbstractUnit): Boolean;
var
  Reason: string;
begin
  if CanConstruct(AUnit, Reason) then Result := GetStructure(AUnit).Rebuild(AUnit)
  else Result := False;
end;

constructor TBuildRoadsControl.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
end;

destructor TBuildRoadsControl.Destroy;
begin
  inherited Destroy;
end;

function TBuildRoadsControl.ID: Integer;
begin
  Result := 2;
end;

procedure TBuildRoadsControl.GetInfo(AUnit: TAbstractUnit; var Text: string; var Gold, Days: Integer);
begin
  Text := TranslateRStr(P4BuildRoadRStr);
  Gold := 0;
  Days := 0;
end;

function TBuildRoadsControl.CanConstruct(A1: TAbstractUnit; var A2: string): Boolean;
var
  X, Y, L: Shortint;
begin
  A1.GetLocation(X, Y, L);
  if L = 0 then Result := inherited CanConstruct(A1, A2)
  else
  begin
    Result := False;
    A2 := Format(TranslateRStr(P4CannotBuildUndergroundRStr), [TranslateRStr(P4RoadsRStr)]);
  end;
end;

function TBuildRoadsControl.Construct(AUnit: TAbstractUnit): Boolean;
var
  Reason: string;
begin
  if CanConstruct(AUnit, Reason) then
  begin
    AoWHSMap.FSelectedArmy.SelectBuildRoad(AUnit);
    Result := True;
  end
  else Result := False;
end;

procedure TConstructionControl.GetInfo(AUnit: TAbstractUnit; var Text: string; var Gold, Days: Integer);
begin
  Text := '';
  Gold := 0;
  Days := 0;
end;

function TConstructionControl.CanConstruct(A1: TAbstractUnit; var A2: string): Boolean;
var
  Gold, Days: Integer;
  Text: string;
begin
  GetInfo(A1, Text, Gold, Days);
  if AoWHSMap.FPlayers.GetPlayers(A1.FPlayer).FGems < Gold then
  begin
    A2 := TranslateRStr(P4NotEnoughGoldRStr);
    Result := False;
  end
  else Result := True;
end;

function TConstructionControl.Construct(AUnit: TAbstractUnit): Boolean;
begin
  Result := False;
end;

function TConstructionControl.ID: Integer;
begin Result := 0; end;

function TConstructionControlList.GetConstructionControl(Index: Integer): TConstructionControl;
begin
  Result := TConstructionControl(FChildren.List^[Index]);
end;

function TConstructionControlList.FindID(ID: Integer): TConstructionControl;
var
  I: Integer;
  Control: TConstructionControl;
begin
  Result := nil;
  I := GetCount;
  while (Result = nil) and (I <> 0) do
  begin
    Dec(I);
    Control := TConstructionControl(FChildren.List^[I]);
    if Control.ID = ID then Result := TConstructionControl(FChildren.List^[I]);
  end;
end;

constructor TConstructAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(P4ConstructRStr);
  FAbilityID := 125;
  FAbilityType := atEnhancement;
  FSelectionTypes := [astUnit];
  FConstructionControls := TConstructionControlList.Create(nil);
  RegisterConstructionControl(TRebuildConstructionControl.Create(nil));
  RegisterConstructionControl(TBuildRoadsControl.Create(nil));
end;

destructor TConstructAbility.Destroy;
begin
  FConstructionControls.Free;
  inherited Destroy;
end;

function TConstructAbility.GetControlType: TAbilityControlType;
begin Result := [acAction]; end;

function TConstructAbility.CanActivate(A1: TAbilityOwner; var A2: string): Boolean;
begin
  if A1 is TAbstractUnit then Result := True
  else Result := False;
end;

procedure TConstructAbility.RegisterConstructionControl(Control: TConstructionControl);
var
  ControlID: Integer;
begin
  ControlID := Control.ID;
  if FConstructionControls.FindID(ControlID) <> nil then
    raise Exception.Create('Construction Control ID already used');
  Control.SetOwner(FConstructionControls);
end;

function TAbilityPlugIn.Name: string;
begin
  Result := P4AbilitiesRStr;
end;

function TAbilityPlugIn.Initialize(AEngine: Engine.TEngine): Boolean;
begin
  if AEngine is TAoWEngine then Result := inherited Initialize(AEngine)
  else Result := False;
end;

function TAbilityPlugIn.Finalize(AEngine: Engine.TEngine): Boolean;
begin
  AddRef;
  Result := inherited Finalize(AEngine);
  Release;
end;

function TSpellCC.GetName: string;
var
  Target: TCombatObject;
begin
  Result := Format(TranslateRStr(P4CastXRStr), [AoWHSSet.FSpellControl.GetSpell(FSpellID).FSpellName]);
  Target := FTarget;
  if Target <> nil then Result := Result + ' on ' + Target.IDStr;
end;

constructor TSpell.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellText := TStringList.Create;
  FCastSounds := TSFXLibrary.Create(nil);
  FCastImages := TImageSequenceList.Create(AoWHSSet.ImageLibraryManager, nil);
  FResearchCost := 1;
  FSpellControlTypes := [sctGlobal];
end;

destructor TSpell.Destroy;
begin
  FCastSounds.Free;
  FCastImages.Free;
  FSpellText.Free;
  inherited Destroy;
end;

function TSpell.GetEnabled: Boolean;
asm
  MOV AL, 1
end;

procedure TSpell.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwStrings(FSpellText, 10);
  Stream.rwEObject(FCastSounds, 11);
  Stream.rwStreamProc(12, FCastImages.LoadFromStream, FCastImages.SaveToStream);
  Stream.rwInteger(FBaseManaCost, 13);
  Stream.rwInteger(FManaUpkeep, 14);
  Stream.rwInteger(FResearchCost, 15);
  Stream.rwData(FMagicSphere, 1, 16);
  Stream.rwByte(FSpellLevel, 17);
end;

function TSpell.CanActivate(A1: TAbstractUnit; var A2: string): Boolean;
{ Signature remains compatible with external draft overrides: AL is Boolean,
  EDX is the caster, ECX points to the reason string. }
asm
  PUSH EBP
  MOV EBP, ESP
  PUSH 0
  PUSH 0
  PUSH EBX
  MOV EBX, ECX
  XOR EDX, EDX
  PUSH EBP
  PUSH OFFSET @@Exception
  PUSH DWORD PTR FS:[EDX]
  MOV DWORD PTR FS:[EDX], ESP
  CMP BYTE PTR [EAX + $22], 2
  JNE @@OtherSpell
  MOV EAX, [AoWHSMap]
  MOV EAX, [EAX + $188]
  TEST BYTE PTR [EAX + $10], $40
  JE @@Allowed
  LEA EDX, [EBP - 8]
  MOV EAX, OFFSET P4SpellWardBlocksCastRStr
  CALL System.LoadResString
  MOV EAX, [EBP - 8]
  LEA EDX, [EBP - 4]
  CALL TranslateRStr
  MOV EDX, [EBP - 4]
  MOV EAX, EBX
  CALL System.@LStrAsg
  XOR EBX, EBX
  JMP @@Finally
@@Allowed:
  MOV BL, 1
  JMP @@Finally
@@OtherSpell:
  MOV BL, 1
@@Finally:
  XOR EAX, EAX
  POP EDX
  POP ECX
  POP ECX
  MOV DWORD PTR FS:[EAX], EDX
  PUSH OFFSET @@Return
@@Clear:
  LEA EAX, [EBP - 8]
  MOV EDX, 2
  CALL System.@LStrArrayClr
  RET
@@Exception:
  JMP System.@HandleFinally
  JMP @@Clear
@@Return:
  MOV EAX, EBX
  POP EBX
  POP ECX
  POP ECX
  POP EBP
end;

function TSpell.Activate(A1: TAbstractUnit): Boolean;
{ Original returns false after optionally centering on the seated player's unit. }
asm
  PUSH EBX
  PUSH ECX
  MOV EAX, [AoWHSMap]
  MOV AL, [EAX + $A5]
  CMP AL, [EDX + $24]
  JNE @@Done
  LEA EAX, [ESP + 2]
  PUSH EAX
  LEA ECX, [ESP + 5]
  LEA EAX, [ESP + 4]
  XCHG EDX, EAX
  CALL TAbstractUnit.GetLocation
  CMP BYTE PTR [ESP], $FF
  JE @@Done
  MOVSX EAX, BYTE PTR [ESP + 2]
  PUSH EAX
  PUSH 3
  MOVSX ECX, BYTE PTR [ESP + 9]
  MOVSX EDX, BYTE PTR [ESP + 8]
  MOV EAX, [AoWHSMap]
  MOV EBX, [EAX]
  CALL DWORD PTR [EBX + $C8]
@@Done:
  XOR EAX, EAX
  POP EDX
  POP EBX
end;

function TSpell.CanActivateCombat(A1: TAbstractUnit; var A2: string): Boolean;
asm
  MOV EAX, [AoWHSMap]
  CMP DWORD PTR [EAX + $120], 0
  SETNE AL
end;

function TSpell.ActivateCombat(A1: TAbstractUnit): Boolean;
{ AL is the Boolean result; EDX is a combat object. }
asm
  PUSH EBP
  MOV EBP, ESP
  ADD ESP, -8
  PUSH EBX
  PUSH ESI
  XOR ECX, ECX
  MOV [EBP - 8], ECX
  MOV [EBP - 4], EDX
  MOV ESI, EAX
  XOR EAX, EAX
  PUSH EBP
  PUSH OFFSET @@Exception
  PUSH DWORD PTR FS:[EAX]
  MOV DWORD PTR FS:[EAX], ESP
  LEA ECX, [EBP - 8]
  MOV EDX, [EBP - 4]
  MOV EAX, ESI
  MOV EBX, [EAX]
  CALL DWORD PTR [EBX + $70]
  TEST AL, AL
  JE @@Rejected
  XOR ECX, ECX
  MOV DL, 1
  MOV EAX, [P4CombatCasterClass]
  CALL TCombatSpellCaster.Create
  MOV EBX, EAX
  MOV EAX, [ESI].TSpell.FSpellID
  MOV [EBX + 8], EAX
  MOV EAX, [EBP - 4]
  MOV EAX, [EAX + $18]
  MOV [EBX + $0C], EAX
  MOV EAX, [AoWHSMap]
  MOV EAX, [EAX + $11C]
  MOV EAX, [EAX + $D8]
  MOV EDX, EBX
  CALL TEventList.TriggerNotifyEvents
  MOV EAX, EBX
  MOV EDX, [EAX]
  CALL DWORD PTR [EDX + $2C]
  MOV BL, 1
  JMP @@Finally
@@Rejected:
  XOR EBX, EBX
@@Finally:
  XOR EAX, EAX
  POP EDX
  POP ECX
  POP ECX
  MOV DWORD PTR FS:[EAX], EDX
  PUSH OFFSET @@Return
@@Clear:
  LEA EAX, [EBP - 8]
  CALL System.@LStrClr
  RET
@@Exception:
  JMP System.@HandleFinally
  JMP @@Clear
@@Return:
  MOV EAX, EBX
  POP ESI
  POP EBX
  POP ECX
  POP ECX
  POP EBP
end;

function TSpell.CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction;
asm
  XOR EAX, EAX
end;

procedure TSpell.GetCombatInfo(Source: TAbstractUnit; var Info: TSpellCombatInfo);
{ ECX points to the eight-byte TSpellCombatInfo record. }
asm
  PUSH EBX
  MOV EBX, ECX
  MOV [EBX].TP4CombatInfo.V0, 0
  MOV [EBX].TP4CombatInfo.V1, 0
  MOV AX, [P4EmptyDamageTypes]
  MOV [EBX].TP4CombatInfo.DamageTypes, AX
  MOV [EBX].TP4CombatInfo.V4, 1
  MOV [EBX].TP4CombatInfo.V5, 0
  MOV [EBX].TP4CombatInfo.V6, 0
  MOV AL, [P4EmptyCombatModes]
  MOV [EBX].TP4CombatInfo.Modes, AL
  POP EBX
end;

function TSpell.GetCombatDamageValue(A1, A2: TCombatObject): Integer;
asm
  XOR EAX, EAX
end;

procedure TSpell.GetCombatDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues);
begin
  with PP4DamageValue(@A3)^ do
  begin
    V0 := 0;
    V1 := 0;
    V2 := 0;
    V3 := 0;
    DamageTypes := [];
  end;
end;

procedure TSpell.CastingDone(Source: TAbstractUnit; Mana: Integer);
begin
  if Source is THero then
    THero(Source).CastingDone(FSpellID, Mana);
end;

procedure TSpell.CombatCastingDone(Source: TCombatObject; Mana: Integer);
begin
  if (Source is TCombatUnit) and
    (TObject(TCombatUnit(Source).FUnit) is THero) then
    with TCombatUnit(Source) do
    begin
      THero(FUnit).CastingDone(FSpellID, Mana);
      UpdateWallCombatFeatures;
      if TObject(Source.FCombat) is TFastCombat then
        TFastCombatUnit(Source).UpdateWallSiegeObjectRegistration;
    end;
end;

procedure TSpell.CombatSpellCast(Source: TCombatUnit);
var
  Hero: THeroCastingViewP4;
  Mana: Integer;
begin
  Hero := THeroCastingViewP4(Source.FUnit);
  Mana := Hero.SpellMana(Self);
  CombatCastingDone(Source, Mana);
end;

procedure TSpell.PlayDefaultCastEffects(Player, X, Y, Layer: Shortint);
{ Player/X/Y/Layer use the original byte ABI. }
asm
  PUSH ECX
  PUSH EBX
  PUSH ESI
  PUSH EDI
  MOV EBX, ECX
  MOV BYTE PTR [EBP - 1], DL
  MOV ESI, EAX
  MOV AL, BYTE PTR [EBP + 8]
  PUSH EAX
  PUSH 0
  MOV CL, BYTE PTR [EBP + $0C]
  MOV EDX, EBX
  MOV EAX, [AoWHSMap]
  CALL TAoWHSMap.Visible
  TEST AL, AL
  JE @@Done
  MOV AL, BYTE PTR [EBP + $0C]
  PUSH EAX
  MOV AL, BYTE PTR [EBP + 8]
  PUSH EAX
  PUSH 0
  MOV ECX, EBX
  MOV DL, BYTE PTR [EBP - 1]
  MOV EAX, [AoWHSMap]
  CALL TAoWHSMap.ValidateObservation
  MOV EDX, [ESI].TSpell.FSpellID
  MOV EAX, [AoWHSSet]
  MOV EAX, [EAX + $84]
  CALL TSpellControl.GetSpell
  MOV EAX, [EAX].TSpell.FCastImages
  XOR EDX, EDX
  CALL TImageSequenceList.GetImageSequence
  TEST EAX, EAX
  JE @@Sound
  XOR ECX, ECX
  MOV DL, 1
  MOV EAX, [P4ImageAnimationClass]
  CALL TImageSequenceAnimation.Create
  MOV EDI, EAX
  MOV EDX, [ESI].TSpell.FSpellID
  MOV EAX, [AoWHSSet]
  MOV EAX, [EAX + $84]
  CALL TSpellControl.GetSpell
  MOV EAX, [EAX].TSpell.FCastImages
  XOR EDX, EDX
  CALL TImageSequenceList.GetImageSequence
  MOV EDX, EAX
  MOV EAX, EDI
  CALL TImageSequenceAnimation.SetImageSequence
  MOVSX EAX, BYTE PTR [EBP + $0C]
  PUSH EAX
  MOVSX EAX, BYTE PTR [EBP + 8]
  PUSH EAX
  MOVSX ECX, BL
  MOV EDX, EDI
  MOV EAX, [AoWHSMap]
  CALL THSMap.PlaceHX
@@Sound:
  MOV EAX, [AoWHSMap]
  MOV AL, [EAX + $A5]
  CMP AL, BYTE PTR [EBP - 1]
  JE @@Play
  MOV AL, BYTE PTR [EBP + 8]
  PUSH EAX
  PUSH 0
  MOV CL, BYTE PTR [EBP + $0C]
  MOV EDX, EBX
  MOV EAX, [AoWHSMap]
  CALL TAoWHSMap.Watching
  TEST AL, AL
  JE @@Done
@@Play:
  MOV EDX, [ESI].TSpell.FSpellID
  MOV EAX, [AoWHSSet]
  MOV EAX, [EAX + $84]
  CALL TSpellControl.GetSpell
  MOV EAX, [EAX].TSpell.FCastSounds
  XOR EDX, EDX
  CALL TSFXLibrary.Play
@@Done:
  POP EDI
  POP ESI
  POP EBX
  POP ECX
end;

function TSpell.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
asm
  XOR EAX, EAX
end;

procedure TSpell.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
begin
  FillChar(A4, 20, 0);
end;

procedure TSpell.fcPrefetchCombatCommands(A1: TFastCombatCommandList);
begin end;

function TSpell.fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean;
asm
  XOR EAX, EAX
end;

procedure TSpell.tcGetDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues);
asm
  PUSH EBX
  PUSH ESI
  MOV ESI, EAX
  MOV EAX, A3
  PUSH EAX
  MOV EAX, ESI
  MOV EBX, [EAX]
  CALL DWORD PTR [EBX + $84]
  POP ESI
  POP EBX
end;

procedure TSpell.tcGetDamageValue;
asm
  PUSH EBX
  MOV EBX, [EAX]
  CALL DWORD PTR [EBX + $80]
  POP EBX
end;

function TSpell.CreateCastSpellAction: TAICastSpellAction;
asm
  XOR ECX, ECX
  MOV DL, 1
  MOV EAX, [P4CastSpellActionClass]
  CALL TEObject.Create
end;

procedure TSpell.SetupCastSpellAction(A1: TAbstractUnit; A2: TAICastSpellAction);
asm
  MOV EAX, [EAX].TSpell.FSpellID
  MOV [ECX + $0C], EAX
  MOV EAX, [EDX + $18]
  MOV [ECX + $08], EAX
end;

function TSpell.AIRequestCastSpellExpense(Source: TAbstractUnit; Budget, Mana, Upkeep: Integer): Boolean;
var
  Manager: TAIBudgetManager;
begin
  if Upkeep > 0 then
  begin
    Dec(Mana, P4RequestUpkeep(TPlayerMagicControl(P4GetPlayer(
      TPlayerList(AoWHSMap.FPlayers), ShortInt(Source.FPlayer)).FMagicControl),
      Round(Upkeep * 0.8)));
    if Mana < 0 then
      Mana := 0;
  end;
  Manager := TAIBudgetManager(P4GetPlayer(TPlayerList(AoWHSMap.FPlayers),
    ShortInt(Source.FPlayer)).FAIBudget);
  if not TPlayerMagicControl(P4GetPlayer(TPlayerList(AoWHSMap.FPlayers),
    ShortInt(Source.FPlayer)).FMagicControl).GetCheatEnabled then
    Result := P4RequestBudget(Manager, 0, Budget, 0, Mana, Integer(Manager.FDefaultBudget), 1)
  else
    Result := True;
end;

function TSpell.AICastSpellExpenseMade(Source: TAbstractUnit; Budget, Mana, Upkeep: Integer): Boolean;
var
  Manager: TAIBudgetManager;
begin
  if AIRequestCastSpellExpense(Source, Budget, Mana, Upkeep) then
  begin
    Manager := TAIBudgetManager(P4GetPlayer(TPlayerList(AoWHSMap.FPlayers),
      ShortInt(Source.FPlayer)).FAIBudget);
    if not TPlayerMagicControl(P4GetPlayer(TPlayerList(AoWHSMap.FPlayers),
      ShortInt(Source.FPlayer)).FMagicControl).GetCheatEnabled then
      Result := P4BudgetMade(Manager, 0, Budget, 0, Mana, Integer(Manager.FDefaultBudget), 2)
    else
      Result := True;
  end
  else
    Result := False;
end;

procedure TSpell.AIPrefetchCastSpellActions(A1: TAbstractUnit; A2: TAICastSpellActionList);
begin end;

function TSpell.AIExecuteCastSpellAction(A1: TAbstractUnit): Boolean;
asm
  XOR EAX, EAX
end;

class function TSpellTE.ClassID: Integer;
begin
  Result := $21300;
end;

procedure TSpellTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FEventSpellID, 15);
  Stream.rwInteger(FEventSourceID, 16);
  Stream.rwByte(FEventPlayerIndex, 17);
  Stream.rwInteger(FEventMana, 18);
end;

procedure TSpellTE.Initialize(SpellID: Integer; PlayerIndex: Byte; SourceID, Mana: Integer);
begin
  FEventSpellID := SpellID;
  FEventSourceID := SourceID;
  FEventPlayerIndex := PlayerIndex;
  FEventMana := Mana;
end;

function TSpellTE.GetSource: TAbstractUnit;
asm
  MOV EDX, [AoWHSMap]
  MOV EDX, [EDX + $FC]
  MOV EAX, [EAX].TSpellTE.FEventSourceID
  XCHG EDX, EAX
  CALL TUnitControl.FindUnit
end;

function TSpellTE.Validate(A1: THero): Boolean;
{ AL is Boolean. The original assumes the source supports THero's instant-cast API. }
asm
  PUSH EBP
  MOV EBP, ESP
  PUSH 0
  PUSH EBX
  PUSH ESI
  MOV ESI, EDX
  MOV EBX, EAX
  XOR EAX, EAX
  PUSH EBP
  PUSH OFFSET @@Exception
  PUSH DWORD PTR FS:[EAX]
  MOV DWORD PTR FS:[EAX], ESP
  MOV AL, [ESI + $24]
  CMP AL, [EBX].TSpellTE.FEventPlayerIndex
  JNE @@No
  LEA EAX, [EBP - 4]
  PUSH EAX
  MOV ECX, [EBX].TSpellTE.FEventMana
  MOV EDX, [EBX].TSpellTE.FEventSpellID
  MOV EAX, ESI
  CALL THero.CanCastSpellInstantly
  TEST AL, AL
  JNE @@Yes
@@No:
  XOR EAX, EAX
  JMP @@Finally
@@Yes:
  MOV AL, 1
@@Finally:
  MOV EBX, EAX
  XOR EAX, EAX
  POP EDX
  POP ECX
  POP ECX
  MOV DWORD PTR FS:[EAX], EDX
  PUSH OFFSET @@Return
@@Clear:
  LEA EAX, [EBP - 4]
  CALL System.@LStrClr
  RET
@@Exception:
  JMP System.@HandleFinally
  JMP @@Clear
@@Return:
  MOV EAX, EBX
  POP ESI
  POP EBX
  POP ECX
  POP EBP
end;

function TSpellTE.Process(A1: TAbstractUnit; A2: Integer): Boolean;
asm
  PUSH EBX
  PUSH ESI
  PUSH EDI
  MOV EDI, ECX
  MOV ESI, EDX
  MOV EBX, EAX
  PUSH EDI
  MOV EAX, [AoWHSSet]
  MOV EAX, [EAX + $84]
  MOV EDX, [EBX].TSpellTE.FEventSpellID
  CALL TSpellControl.GetSpell
  MOV ECX, ESI
  MOV EDX, EBX
  MOV EBX, [EAX]
  CALL DWORD PTR [EBX + $50]
  POP EDI
  POP ESI
  POP EBX
end;

function TSpellTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
var
  Control: TUnitControlCallViewP4;
  Source: TAbstractUnit;
begin
  inherited Execute(TE);
  Control := TUnitControlCallViewP4(AoWHSMap.FUnitControl);
  Source := Control.FindUnitResult(FEventSourceID);
  if (Source <> nil) and ((PP4TokenExecuterState(TE)^.ExecuteCount <> 0) or
    TSpellTECallViewP4(Self).ValidateValue(Source)) then
  begin
    if TSpellTECallViewP4(Self).ProcessValue(Source, PP4TokenExecuterState(TE)^.ExecuteCount) then
      Result := erRetry
    else
      Result := erDone;
  end
  else
    Result := erDoneHalt;
end;

procedure TSpellTE.PlayDefaultCastEffects(A1: Integer; A2: Integer);
{ The draft A1/A2 are unused; the event's source provides player and location. }
asm
  PUSH EBX
  PUSH ECX
  MOV EBX, EAX
  LEA EAX, [ESP + 2]
  PUSH EAX
  MOV EAX, EBX
  CALL TSpellTE.GetSource
  LEA ECX, [ESP + 5]
  LEA EDX, [ESP + 4]
  CALL TAbstractUnit.GetLocation
  MOV AL, BYTE PTR [ESP + 1]
  PUSH EAX
  MOV AL, BYTE PTR [ESP + 6]
  PUSH EAX
  MOV EAX, [AoWHSSet]
  MOV EAX, [EAX + $84]
  MOV EDX, [EBX].TSpellTE.FEventSpellID
  CALL TSpellControl.GetSpell
  PUSH EAX
  MOV EAX, EBX
  CALL TSpellTE.GetSource
  MOV DL, [EAX + $24]
  MOV CL, BYTE PTR [ESP + $0C]
  POP EAX
  MOV EBX, [EAX]
  CALL DWORD PTR [EBX + $4C]
  POP EDX
  POP EBX
end;

constructor TSpellControl.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FRegisteredSpells := TList.Create;
end;

destructor TSpellControl.Destroy;
begin
  UnregisterAll;
  FRegisteredSpells.Free;
  inherited Destroy;
end;

procedure TSpellControl.ReadWrite(Stream: Engine.TEStorageStream);
var
  I: Integer;
begin
  inherited ReadWrite(Stream);
  for I := 0 to FRegisteredSpells.Count - 1 do
    if FRegisteredSpells[I] <> nil then
      Stream.rwEObject(TSpell(FRegisteredSpells[I]), I + 10);
end;

function TSpellControl.GetCount: Integer;
begin
  Result := FRegisteredSpells.Count;
end;

function TSpellControl.GetSpell(Index: Integer): TSpell;
{ conflict: function TSpellControl.GetSpell(SpellID: Integer): TSpell; }
begin
  Assert(Index >= 0);
  if Index < FRegisteredSpells.Count then
    Result := TSpell(FRegisteredSpells[Index])
  else
    Result := nil;
end;

procedure TSpellControl.RegisterSpell(Spell: TSpell);
var
  ID: Integer;
begin
  ID := Spell.FSpellID;
  if ID <> 0 then
  begin
    if (ID < FRegisteredSpells.Count) and (FRegisteredSpells[ID] <> nil) then
      raise Exception.Create('Spell already registered (' + IntToStr(ID) + ')');
    while FRegisteredSpells.Count <= ID do
      FRegisteredSpells.Add(nil);
    FRegisteredSpells.List^[ID] := Spell;
    Spell.FCastImages.LinkToIL;
  end
  else
    raise Exception.Create('Invalid SpellID (' + Spell.ClassName + ')');
end;

procedure TSpellControl.UnregisterSpell(Spell: TSpell);
var
  ID: Integer;
begin
  ID := Spell.FSpellID;
  if ID <> 0 then
  begin
    if (ID < 0) or (ID >= FRegisteredSpells.Count) or (FRegisteredSpells[ID] <> Spell) then
      raise Exception.Create('Cannot Unregister Spell (' + IntToStr(ID) + ')');
    if FRegisteredSpells.List^[ID] <> nil then
    begin
      Spell.FCastImages.ReleaseIL;
      TSpell(FRegisteredSpells.List^[ID]).Free;
      FRegisteredSpells.List^[ID] := nil;
    end;
  end
  else
    raise Exception.Create('Invalid SpellID (' + Spell.ClassName + ')');
end;

procedure TSpellControl.UnregisterSpellID(A1: Integer);
begin
  if FRegisteredSpells.List^[A1] <> nil then
    UnregisterSpell(TSpell(FRegisteredSpells.List^[A1]));
end;

procedure TSpellControl.UnregisterAll;
var
  I: Integer;
begin
  for I := FRegisteredSpells.Count - 1 downto 0 do
    if FRegisteredSpells[I] <> nil then
      UnregisterSpell(TSpell(FRegisteredSpells[I]));
end;

procedure TSpellControl.ListSpells(SpellStrings: TStrings; Spheres: TMagicSpheres);
var
  I: Integer;
begin
  SpellStrings.Clear;
  with FRegisteredSpells do
    for I := 0 to Count - 1 do
      if (List^[I] <> nil) and (TSpell(List^[I]).FMagicSphere in Spheres) then
        SpellStrings.AddObject(TSpell(List^[I]).FSpellName, TObject(I));
end;

function TSpellControl.GetRandomSpell(MinLevel, MaxLevel: Integer; Spheres: TMagicSpheres): Integer;
var
  Candidates: TIntegerList;
  I: Integer;
  Spell: TSpell;
begin
  Candidates := TIntegerList.Create;
  with FRegisteredSpells do
    for I := Count - 1 downto 0 do
    begin
      Spell := TSpell(List^[I]);
      if (Spell <> nil) and (Spell.FMagicSphere in Spheres) and
        (Spell.FSpellLevel >= MinLevel) and (Spell.FSpellLevel <= MaxLevel) then
        Candidates.Add(I);
    end;
  if Candidates.Count <> 0 then
    Result := Candidates[P4MapRandom(AoWHSMap, Candidates.Count)]
  else
    Result := 0;
  Candidates.Free;
end;

constructor TSpellList.Create;
begin
  inherited Create;
  FSpells := TList.Create;
end;

destructor TSpellList.Destroy;
begin
  FSpells.Free;
  inherited Destroy;
end;

function TSpellList.GetSpell(Index: Integer): TSpell;
begin
  if (Index >= 0) and (Index < GetCount) then
    Result := TSpell(FSpells[Index])
  else
    Result := nil;
end;

function TSpellList.GetCount: Integer;
begin
  Result := FSpells.Count;
end;

procedure TSpellList.Add(Spell: TSpell);
begin
  FSpells.Add(Spell);
end;

procedure TSpellList.Delete(Index: Integer);
begin
  FSpells.Delete(Index);
end;

procedure TSpellList.Clear;
begin
  FSpells.Clear;
end;

function P4CompareSpellNames(Item1, Item2: Pointer): Integer;
begin
  Result := CompareText(TSpell(Item1).FSpellName, TSpell(Item2).FSpellName);
  if Result = 0 then
    Result := TSpell(Item1).FSpellLevel - TSpell(Item2).FSpellLevel;
end;

function P4CompareSpellLevels(Item1, Item2: Pointer): Integer;
begin
  Result := TSpell(Item1).FSpellLevel - TSpell(Item2).FSpellLevel;
  if Result = 0 then
    Result := CompareText(TSpell(Item1).FSpellName, TSpell(Item2).FSpellName);
end;

procedure TSpellList.SortOnName;
begin
  FSpells.Sort(P4CompareSpellNames);
end;

procedure TSpellList.SortOnLevel;
begin
  FSpells.Sort(P4CompareSpellLevels);
end;

constructor TSpellCaster.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FCasterRefCount := 1;
end;

function TSpellCaster.AddRef: Integer;
begin
  Inc(FCasterRefCount);
  Result := FCasterRefCount;
end;

function TSpellCaster.Release: Integer;
var
  Count, ReleasedCount: Integer;
begin
  Dec(FCasterRefCount);
  Count := FCasterRefCount;
  ReleasedCount := Count;
  if Count = 0 then
    Destroy;
  Result := ReleasedCount;
end;

function TSpellCaster.GetSource: TAbstractUnit;
{ needs: P2 TUnitControl.FindUnit returns TAbstractUnit; 5577A140. }
asm
  MOV EDX, [AoWHSMap]
  MOV EDX, [EDX + $FC]
  MOV EAX, [EAX].TSpellCaster.FCasterSourceID
  XCHG EDX, EAX
  CALL TUnitControl.FindUnit
end;

function TSpellCaster.CanCast(var Reason: string): Boolean;
{ Reason is unused; AL reports whether the source still exists. }
asm
  MOV EDX, [AoWHSMap]
  MOV EDX, [EDX + $FC]
  MOV EAX, [EAX].TSpellCaster.FCasterSourceID
  XCHG EDX, EAX
  CALL TUnitControl.FindUnit
  TEST EAX, EAX
  SETNE AL
end;

function TSpellCaster.Cast: Boolean;
asm
  MOV AL, 1
end;

constructor TCombatSpellCaster.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FCombatCasterRefCount := 1;
end;

function TCombatSpellCaster.AddRef: Integer;
begin
  Inc(FCombatCasterRefCount);
  Result := FCombatCasterRefCount;
end;

function TCombatSpellCaster.Release: Integer;
var
  Count, ReleasedCount: Integer;
begin
  Dec(FCombatCasterRefCount);
  Count := FCombatCasterRefCount;
  ReleasedCount := Count;
  if Count = 0 then
    Destroy;
  Result := ReleasedCount;
end;

class function TSpellCastEventLog.ClassID: Integer;
begin
  Result := $202EF;
end;

function TSpellCastEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
var
  Show: Boolean;
  Hero: THero;
  Reason: string;
begin
  Show := Trigger = etUser;
  Show := Show or ((AoWHSMap.FPlayMode = pmTurn) and
    (wpSpellReady in AoWEngine.FRegistry.GetClassicWindowPopupEvents));
  Show := Show or ((AoWHSMap.FPlayMode = pmSimultaneous) and
    (wpSpellReady in AoWEngine.FRegistry.GetSimultaneousWindowPopupEvents));
  if Show then
  begin
    Hero := THero(AoWHSMap.FUnitControl.FindUnit(FUnitID));
    if (Hero is THero) and (Hero.FCastingSpellID = FSpellID) and Hero.CastingReady then
      AoWHSSet.FAbilityControl.GetAbility(52).Activate(Hero, Reason);
  end;
  Result := False;
end;

procedure TSpellCastEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FUnitID, 20);
  Stream.rwInteger(FSpellID, 21);
end;

procedure TSpellCastEventLog.ViewLocation;
var
  AUnit: TAbstractUnit;
  X, Y, L: Shortint;
begin
  AUnit := AoWHSMap.FUnitControl.FindUnit(FUnitID);
  if AUnit <> nil then
  begin
    AUnit.GetLocation(X, Y, L);
    CenterViewTo(X, Y, L);
  end;
end;

function TSpellCastEventLog.GetText: string;
begin
  Result := Format(TranslateRStr(P4XCastingReadyRStr), [AoWHSSet.FSpellControl.GetSpell(FSpellID).FSpellName]);
end;

constructor TUnitSpellCaster.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FTargetUnits := TUnitUserList.Create(nil);
end;

destructor TUnitSpellCaster.Destroy;
begin
  FTargetUnits.Free;
  inherited Destroy;
end;

procedure TUnitSpellCaster.SetSelection(Selection: Byte);
asm
  PUSH EBX
  PUSH ESI
  PUSH ECX
  MOV BYTE PTR [ESP], DL
  MOV EBX, EAX
  MOV EAX, [AoWHSMap]
  MOV EAX, [EAX + $FC]
  MOV EDX, [EBX].TSpellCaster.FCasterSourceID
  CALL TUnitControl.FindUnit
  MOV ESI, EAX
  PUSH ESP
  MOV EAX, [AoWHSSet]
  MOV EAX, [EAX + $84]
  MOV EDX, [EBX].TSpellCaster.FCasterSpellID
  CALL TSpellControl.GetSpell
  MOV ECX, [EBX].TUnitSpellCaster.FTargetUnits
  MOV EDX, ESI
  MOV ESI, [EAX]
  CALL DWORD PTR [ESI + $A0]
  MOV AL, BYTE PTR [ESP]
  MOV [EBX].TUnitSpellCaster.FSelectionMask, AL
  POP EDX
  POP ESI
  POP EBX
end;

function TUnitSpellCaster.GetSelectionCount: Integer;
var
  Bits: Integer;
begin
  Result := 0;
  Bits := FSelectionMask;
  while Bits <> 0 do
  begin
    if (Bits and 1) <> 0 then
      Inc(Result);
    Bits := Bits shr 1;
  end;
end;

function TUnitSpellCaster.GetRequiredMana: Integer;
var
  Hero: THeroCastingViewP4;
  Mana, Count: Integer;
begin
  Hero := THeroCastingViewP4(PP4MapUnitControl(AoWHSMap)^.UnitControl.FindUnitResult(FCasterSourceID));
  if Hero <> nil then
  begin
    Mana := Hero.SpellMana(TSpellControl(AoWHSSet.FSpellControl).GetSpell(FCasterSpellID));
    Count := GetSelectionCount;
    Mana := Mana * Count;
    Result := Mana;
  end
  else
    Result := -1;
end;

function TUnitSpellCaster.GetRequiredDays: Integer;
var
  Hero: TCastingPointsReturnViewP4;
  Deficit: Integer;
begin
  Hero := TCastingPointsReturnViewP4(PP4MapUnitControl(AoWHSMap)^.UnitControl.FindUnitResult(FCasterSourceID));
  if (Hero <> nil) and (Hero.CastingPointsMax <> 0) then
  begin
    Deficit := GetRequiredMana - Hero.CastingPoints;
    if Deficit > 0 then
    begin
      Result := Deficit div Hero.CastingPointsMax;
      { Original bug: the remainder uses current points, not maximum points. }
      if Deficit mod Hero.CastingPoints <> 0 then
        Inc(Result);
    end
    else
      Result := 0;
  end
  else
    Result := 0;
end;

function TUnitSpellCaster.CanCast(var Reason: string): Boolean;
{ Compatibility body: Boolean result in AL; source/selection validation and casting. }
asm
  PUSH ebp
  MOV ebp, esp
  PUSH 0
  PUSH 0
  PUSH 0
  PUSH ebx
  PUSH esi
  PUSH edi
  MOV dword ptr [ebp - 4], edx
  MOV esi, eax
  XOR eax, eax
  PUSH ebp
  PUSH OFFSET @@L170
  PUSH dword ptr fs:[eax]
  MOV dword ptr fs:[eax], esp
  MOV eax, dword ptr [AoWHSMap]
  MOV eax, dword ptr [eax + $FC]
  MOV edx, dword ptr [esi].TSpellCaster.FCasterSourceID
  CALL TUnitControl.FindUnit
  MOV ebx, eax
  TEST ebx, ebx
  JE @@L153
  TEST byte ptr [ebx + $25], $10
  JNE @@L153
  CMP byte ptr [esi].TUnitSpellCaster.FSelectionMask, 0
  JE @@L12C
  MOVSX edx, byte ptr [ebx + $24]
  MOV eax, dword ptr [AoWHSMap]
  MOV eax, dword ptr [eax + $140]
  CALL TPlayerList.GetPlayers
  MOV eax, dword ptr [eax + $54]
  CALL TPlayerMagicControl.GetCheatEnabled
  TEST al, al
  JNE @@L128
  MOV eax, esi
  CALL TUnitSpellCaster.GetRequiredMana
  MOV edi, eax
  MOV eax, ebx
  CALL THero.CastingReady
  TEST al, al
  JE @@LA9
  MOV eax, dword ptr [ebx + $84]
  CMP eax, dword ptr [esi].TSpellCaster.FCasterSpellID
  JNE @@LA9
  MOV eax, dword ptr [AoWHSSet]
  MOV eax, dword ptr [eax + $84]
  MOV edx, dword ptr [esi].TSpellCaster.FCasterSpellID
  CALL TSpellControl.GetSpell
  SUB EDI, [EAX].TSpell.FBaseManaCost
@@LA9:
  MOV eax, ebx
  MOV edx, dword ptr [eax]
  CALL dword ptr [edx + $12C]
  MOVSX eax, al
  CMP edi, eax
  JG @@L101
  MOVSX edx, byte ptr [ebx + $24]
  MOV eax, dword ptr [AoWHSMap]
  MOV eax, dword ptr [eax + $140]
  CALL TPlayerList.GetPlayers
  MOV eax, dword ptr [eax + $54]
  CMP edi, dword ptr [eax + $24]
  JG @@LDA
  MOV bl, 1
  JMP @@L155
@@LDA:
  XOR ebx, ebx
  LEA edx, [ebp - $C]
  MOV eax, OFFSET NotEnoughManaRStr
  CALL System.LoadResString
  MOV eax, dword ptr [ebp - $C]
  LEA edx, [ebp - 8]
  CALL TranslateRStr
  MOV edx, dword ptr [ebp - 8]
  MOV eax, dword ptr [ebp - 4]
  CALL System.@LStrAsg
  JMP @@L155
@@L101:
  XOR ebx, ebx
  LEA edx, [ebp - $C]
  MOV eax, OFFSET NotEnoughCastingPointsRStr
  CALL System.LoadResString
  MOV eax, dword ptr [ebp - $C]
  LEA edx, [ebp - 8]
  CALL TranslateRStr
  MOV edx, dword ptr [ebp - 8]
  MOV eax, dword ptr [ebp - 4]
  CALL System.@LStrAsg
  JMP @@L155
@@L128:
  MOV bl, 1
  JMP @@L155
@@L12C:
  XOR ebx, ebx
  LEA edx, [ebp - $C]
  MOV eax, OFFSET NoUnitSelectedRStr
  CALL System.LoadResString
  MOV eax, dword ptr [ebp - $C]
  LEA edx, [ebp - 8]
  CALL TranslateRStr
  MOV edx, dword ptr [ebp - 8]
  MOV eax, dword ptr [ebp - 4]
  CALL System.@LStrAsg
  JMP @@L155
@@L153:
  XOR ebx, ebx
@@L155:
  XOR eax, eax
  POP edx
  POP ecx
  POP ecx
  MOV dword ptr fs:[eax], edx
  PUSH OFFSET @@L177
@@L162:
  LEA eax, [ebp - $C]
  MOV edx, 2
  CALL System.@LStrArrayClr
  RET
@@L170:
  JMP System.@HandleFinally
  JMP @@L162
@@L177:
  MOV eax, ebx
  POP edi
  POP esi
  POP ebx
  MOV esp, ebp
  POP ebp
  RET
end;

function TUnitSpellCaster.Cast: Boolean;
{ Compatibility body: Boolean result in AL; source/selection validation and casting. }
asm
  PUSH ebp
  MOV ebp, esp
  ADD esp, -$C
  PUSH ebx
  PUSH esi
  PUSH edi
  XOR edx, edx
  MOV dword ptr [ebp - 8], edx
  MOV ebx, eax
  XOR eax, eax
  PUSH ebp
  PUSH OFFSET @@LE5
  PUSH dword ptr fs:[eax]
  MOV dword ptr fs:[eax], esp
  LEA edx, [ebp - 8]
  MOV eax, ebx
  MOV ecx, dword ptr [eax]
  CALL dword ptr [ecx + $4C]
  TEST al, al
  JE @@LCD
  MOV eax, dword ptr [AoWHSMap]
  MOV eax, dword ptr [eax + $FC]
  MOV edx, dword ptr [ebx].TSpellCaster.FCasterSourceID
  CALL TUnitControl.FindUnit
  MOV dword ptr [ebp - $C], eax
  CMP dword ptr [ebp - $C], 0
  JE @@LC9
  XOR ecx, ecx
  MOV dl, 1
  MOV eax, dword ptr [P4UnitSelectionClass]
  CALL TEChangeNotifyNode.Create
  MOV dword ptr [ebp - 4], eax
  MOV eax, dword ptr [ebx].TUnitSpellCaster.FTargetUnits
  MOV edx, dword ptr [eax]
  CALL dword ptr [edx + $54]
  MOV edi, eax
  DEC edi
  TEST edi, edi
  JL @@L9C
  INC edi
  XOR esi, esi
@@L6F:
  MOV ecx, esi
  MOV eax, 1
  SHL eax, cl
  XOR edx, edx
  MOV dl, byte ptr [ebx].TUnitSpellCaster.FSelectionMask
  AND eax, edx
  JE @@L98
  MOV edx, esi
  MOV eax, dword ptr [ebx].TUnitSpellCaster.FTargetUnits
  CALL TUnitList.GetUnit
  MOV edx, eax
  MOV eax, dword ptr [ebp - 4]
  MOV ecx, dword ptr [eax]
  CALL dword ptr [ecx + $AC]
@@L98:
  INC esi
  DEC edi
  JNE @@L6F
@@L9C:
  MOV eax, dword ptr [AoWHSSet]
  MOV eax, dword ptr [eax + $84]
  MOV edx, dword ptr [ebx].TSpellCaster.FCasterSpellID
  CALL TSpellControl.GetSpell
  MOV ecx, dword ptr [ebp - 4]
  MOV edx, dword ptr [ebp - $C]
  MOV ebx, dword ptr [eax]
  CALL dword ptr [ebx + $A8]
  MOV ebx, eax
  MOV eax, dword ptr [ebp - 4]
  CALL TObject.Free
  JMP @@LCF
@@LC9:
  MOV bl, 1
  JMP @@LCF
@@LCD:
  XOR ebx, ebx
@@LCF:
  XOR eax, eax
  POP edx
  POP ecx
  POP ecx
  MOV dword ptr fs:[eax], edx
  PUSH OFFSET @@LEC
@@LDC:
  LEA eax, [ebp - 8]
  CALL System.@LStrClr
  RET
@@LE5:
  JMP System.@HandleFinally
  JMP @@LDC
@@LEC:
  MOV eax, ebx
  POP edi
  POP esi
  POP ebx
  MOV esp, ebp
  POP ebp
  RET
end;

function TUnitSpellCaster.Valid: Boolean;
{ Original 5577A7F0 saves Self in EBX even though it is used only before FindUnit.
  Direct calls, separate Control/ID/This locals, ancestor/descendant casts, with
  and reversed Boolean branches all omit that save with this compiler. }
var
  Source: TAbstractUnit;
begin
  Source := PP4MapUnitControl(AoWHSMap)^.UnitControl.FindUnitResult(FCasterSourceID);
  if (Source = nil) or ((Byte(Source.FUnitStatus) and $10) <> 0) then
    Result := False
  else
    Result := True;
end;

class function TUnitSpellCA.ClassID: Integer;
begin
  Result := $202C3;
end;

procedure TUnitSpellCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FSpellID, 20);
  Stream.rwByte(FSourceID, 21);
  Stream.rwByte(FTargetID, 22);
  Stream.rwData(FSpellData, 8, 23);
  Stream.rwInteger(FMana, 24);
end;

procedure TUnitSpellCA.Execute(A1: TCombat);
begin
  TUnitSpell(AoWHSSet.FSpellControl.GetSpell(FSpellID)).ExecuteCA(A1, Self);
end;

function TUnitSpellCA.Play(A1: TCombatViewer): Boolean;
begin
  Execute(A1.FCombat);
  Result := False;
end;

constructor TUnitSpellTE.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FTargetUnitIDs := TIntegerList.Create;
  FTargetUnits := TUnitUserList.Create(nil);
end;

destructor TUnitSpellTE.Destroy;
begin
  FTargetUnitIDs.Free;
  FTargetUnits.Free;
  inherited Destroy;
end;

class function TUnitSpellTE.ClassID: Integer;
begin
  Result := $21308;
end;

procedure TUnitSpellTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwStreamProc(30, FTargetUnitIDs.LoadFromStream, FTargetUnitIDs.SaveToStream);
  Stream.rwData(FSpellData, 8, 31);
  Stream.rwByte(FTargetPlayer, 32);
end;

procedure TUnitSpellTE.Initialize(SpellID: Integer; Source: TAbstractUnit; Targets: TUnitList; Mana: Integer);
var
  I: Integer;
begin
  FEventSpellID := SpellID;
  FEventPlayerIndex := Source.FPlayer;
  FEventSourceID := Source.FUnitID;
  FEventMana := Mana;
  if (Targets <> nil) and (Targets.GetCount <> 0) then
  begin
    FTargetPlayer := Targets.GetUnit(0).FPlayer;
    for I := 0 to Targets.GetCount - 1 do
      FTargetUnitIDs.Add(Targets.GetUnit(I).FUnitID);
  end
  else FTargetPlayer := $FF;
end;

function TUnitSpellTE.Validate(A1: THero): Boolean;
var
  I: Integer;
  Target: TAbstractUnit;
  X, Y, L, TargetX, TargetY, TargetL: Shortint;
begin
  Result := inherited Validate(A1);
  A1.GetLocation(X, Y, L);
  I := FTargetUnitIDs.Count;
  while Result and (I <> 0) do
  begin
    Dec(I);
    Target := AoWHSMap.FUnitControl.FindUnit(FTargetUnitIDs[I]);
    if Target <> nil then
    begin
      Target.GetLocation(TargetX, TargetY, TargetL);
      Result := (Target.GetHitPoints <> 0) and (Byte(Target.FPlayer) = FTargetPlayer);
      if Result then
        if TUnitSpell(AoWHSSet.FSpellControl.GetSpell(FEventSpellID)).FTargetRange <> -1 then
          Result := dHXtoRad(X, Y, TargetX, TargetY) <=
            TUnitSpell(AoWHSSet.FSpellControl.GetSpell(FEventSpellID)).FTargetRange;
      FTargetUnits.AddUnit(Target);
    end
    else Result := False;
  end;
end;

function TUnitSpellTE.Process(A1: TAbstractUnit; A2: Integer): Boolean;
var
  I: Integer;
  Target: TAbstractUnit;
  X, Y, L: Shortint;
begin
  inherited Process(A1, A2);
  if FTargetUnits.GetCount <> 0 then
  begin
    FTargetUnits.GetUnit(0).GetLocation(X, Y, L);
    AoWHSSet.FSpellControl.GetSpell(FEventSpellID).PlayDefaultCastEffects(A1.FPlayer, X, Y, L);
    for I := 0 to FTargetUnits.GetCount - 1 do
    begin
      Target := FTargetUnits.GetUnit(I);
      Target.AddRef;
      if TUnitSpell(AoWHSSet.FSpellControl.GetSpell(FEventSpellID)).ExecuteSpell(A1, Target, FEventMana, FSpellData) then
      begin
        AoWHSSet.FSpellControl.GetSpell(FEventSpellID).CastingDone(A1, FEventMana);
        Target.Changed;
      end;
      Target.Release;
    end;
  end;
  Result := False;
end;

constructor TUnitSpell.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TUnitSpell.GetCombatInfo(Source: TAbstractUnit; var Info: TSpellCombatInfo);
begin end;

function TUnitSpell.ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean;
begin Result := False; end;

function TUnitSpell.ValidTargetUnit(Source, Target: TAbstractUnit): Boolean;
begin Result := False; end;

procedure TUnitSpell.ValidateUnitSelection(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TUnitSpell.SetupUSC(A1: Integer; A2: Integer; A3: Integer);
begin end;

function TUnitSpell.CastSpell(Source: TAbstractUnit; Targets: TUnitList): Boolean;
begin Result := False; end;

procedure TUnitSpell.OnValidateTarget(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TUnitSpell.OnTargetSelectionChange(A1: Integer; A2: Integer);
begin end;

procedure TUnitSpell.ResetTargetSelection;
begin end;

procedure TUnitSpell.SetupTargetSelection(A1: Integer; A2: Integer);
begin end;

function TUnitSpell.ValidTargetParty(Source: TAbstractUnit; Party: TArmyHS): Boolean;
begin Result := False; end;

procedure TUnitSpell.TargetPartySelected(A1: Integer; A2: Integer);
begin end;

function TUnitSpell.Activate(A1: TAbstractUnit): Boolean;
begin Result := False; end;

function TUnitSpell.CanActivateCombat(A1: TAbstractUnit; var A2: string): Boolean;
begin Result := False; end;

function TUnitSpell.CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction;
begin Result := nil; end;

procedure TUnitSpell.CreateCAEx(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TUnitSpell.ExecuteCA(Combat: TCombat; Action: TUnitSpellCA);
begin end;

procedure TUnitSpell.AIRetrieveOptimalTargetUnit(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TUnitSpell.AIPrefetchCastSpellActions(A1: TAbstractUnit; A2: TAICastSpellActionList);
begin end;

function TUnitSpell.AIExecuteCastSpellAction(A1: TAbstractUnit): Boolean;
begin Result := False; end;

class function TResearchSpellAIPA.Priority: Integer;
begin Result := 0; end;

function TResearchSpellAIPA.Process: Boolean;
begin Result := False; end;

procedure TAICastSpellActionList.GetCastSpellActions(A1: Integer);
begin end;

procedure TAICastSpellActionList.SortOnPriority;
begin end;

constructor TCastSpellAIPA.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TCastSpellAIPA.Destroy;
begin end;

class function TCastSpellAIPA.Priority: Integer;
begin Result := 0; end;

function TCastSpellAIPA.Activate: Boolean;
begin Result := False; end;

procedure TCastSpellAIPA.PrefetchCastSpellActions(A1: Integer);
begin end;

procedure TCastSpellAIPA.CastingHeroesMax;
begin end;

procedure TCastSpellAIPA.ProcessStates;
begin end;

function TCastSpellAIPA.Process: Boolean;
begin Result := False; end;

constructor TEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

function TEnchantment.GetName: string;
begin Result := ''; end;

function TEnchantment.GetBinding: string;
begin Result := ''; end;

procedure TEnchantment.GetLocation(var A1, A2, A3: Shortint);
begin end;

procedure TEnchantment.CenterToLocation;
begin end;

procedure TEnchantment.Select;
begin end;

procedure TEnchantment.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TEnchantment.SetUpkeep(A1: Integer);
begin end;

procedure TEnchantment.SetSource(Player: Shortint);
begin end;

function TEnchantment.Dispel: Boolean;
begin Result := False; end;

function TEnchantment.DispelChance(A1: Integer): Integer;
begin Result := 0; end;

function TEnchantment.GetAIUpkeepPriority: Integer;
begin Result := 0; end;

function TEnchantmentList.GetEnchantments(A1: Integer): TEnchantment;
begin Result := nil; end;

procedure TEnchantmentList.IndexOfID(A1: Integer);
begin end;

function TEnchantmentList.FindID(A1: Integer): TEnchantment;
begin Result := nil; end;

function TPowerSource.Name: string;
begin
  Result := '';
end;

function TPowerSource.Power: Integer;
asm
  XOR EAX, EAX
end;

procedure TPowerSource.GetLocation(var A1, A2, A3: Shortint);
begin
  A1 := -1;
  A2 := -1;
  A3 := -1;
end;

procedure TPowerSource.CenterToLocation(A1: Integer; A2: Integer);
{ A1 and A2 are unused draft parameters; the original takes no explicit arguments. }
asm
  PUSH EBX
  PUSH ECX
  LEA EDX, [ESP + 2]
  PUSH EDX
  LEA ECX, [ESP + 5]
  LEA EDX, [ESP + 4]
  MOV EBX, [EAX]
  CALL DWORD PTR [EBX + $54]
  CMP BYTE PTR [ESP], $FF
  JE @@Done
  MOVSX EAX, BYTE PTR [ESP + 2]
  PUSH EAX
  MOVSX ECX, BYTE PTR [ESP + 5]
  MOVSX EDX, BYTE PTR [ESP + 4]
  MOV EAX, [AoWHSMap]
  MOV EBX, [EAX]
  CALL DWORD PTR [EBX + $BC]
  MOV AL, BYTE PTR [ESP + 2]
  PUSH EAX
  MOV CL, BYTE PTR [ESP + 5]
  MOV DL, BYTE PTR [ESP + 4]
  MOV EAX, [AoWHSMap]
  CALL TAbstractAoWHSMap.PlayCenterAnimation
@@Done:
  POP EDX
  POP EBX
end;

procedure TPowerSource.Select;
begin end;

procedure TPowerSourceList.GetItems(A1: Integer);
asm
  MOV EAX, [EAX + 8]
  MOV EAX, [EAX + 4]
  MOV EAX, [EAX + EDX * 4]
end;

function TExternalPowerSource.Name: string;
begin
  P4TranslateInto(P4ExternalPowerRStr, Result);
end;

function TExternalPowerSource.Power: Integer;
{ The external control's unmarked P1 fields retain their existing declaration. }
asm
  MOV EAX, [EAX].TExternalPowerSource.FExternalPowerControl
  MOV EAX, [EAX + $1C]
end;

constructor TPlayerMagicEventLog.Create(AOwner: Engine.TECustomNode);
begin end;

class function TPlayerMagicEventLog.ClassID: Integer;
begin Result := 0; end;

procedure TPlayerMagicEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TPlayerMagicEventLog.ViewLocation;
begin end;

function TPlayerMagicEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
begin end;

function TPlayerMagicEventLog.GetText: string;
begin Result := ''; end;

constructor TPlayerMagicControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TPlayerMagicControl.Destroy;
begin end;

procedure TPlayerMagicControl.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TPlayerMagicControl.GetCheatEnabled: Boolean;
begin
  if TPlayer(FPlayer).FPlayerType = ptHuman then
    Result := Boolean(F_PlayerMagicControl_0C)
  else
    Result := False;
end;

procedure TPlayerMagicControl.SetActiveEnchantments(A1: Byte; A2: Integer);
begin end;

procedure TPlayerMagicControl.UpdateEnemyEnchantments;
begin end;

function TPlayerMagicControl.GetManaIncome: Integer;
begin Result := 0; end;

function TPlayerMagicControl.GetManaUpkeep: Integer;
begin Result := 0; end;

procedure TPlayerMagicControl.SetMana(A1: Integer);
begin end;

procedure TPlayerMagicControl.GetPower;
begin end;

procedure TPlayerMagicControl.OutOfMana(A1: Integer);
begin end;

procedure TPlayerMagicControl.RemoveEnchantments;
begin end;

procedure TPlayerMagicControl.ValidateEnchantmentsUpkeep;
begin end;

procedure TPlayerMagicControl.ExecuteSpellResearched(A1: Integer);
begin end;

procedure TPlayerMagicControl.NewTurn;
begin end;

procedure TPlayerMagicControl.SetSpheres(A1: Word; A2: Integer);
begin end;

procedure TPlayerMagicControl.GetNetPower;
begin end;

procedure TPlayerMagicControl.GetNetPowerToMana(A1: Integer; A2: Integer);
begin end;

procedure TPlayerMagicControl.GetNetPowerToResearch(A1: Integer; A2: Integer);
begin end;

procedure TPlayerMagicControl.ResearchTurns(A1: Integer; A2: Integer);
begin end;

procedure TPlayerMagicControl.GetResearchTurnsLeft;
begin end;

procedure TPlayerMagicControl.ValidResearchSpell(A1: Integer);
begin end;

procedure TPlayerMagicControl.ListResearchSpells(var List: TSpellList; SpellTypes: TSpellTypes);
begin end;

procedure TPlayerMagicControl.ListSpells(var List: TSpellList; SpellTypes: TSpellTypes);
begin end;

procedure TPlayerMagicControl.BeginUpdate;
begin end;

procedure TPlayerMagicControl.EndUpdate;
begin end;

procedure TPlayerMagicControl.Update;
begin end;

procedure TPlayerMagicControl.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TPlayerMagicControl.ValidateEnchantmentID(A1: Integer);
begin end;

procedure TPlayerMagicControl.RegisterEnchantment(Enchantment: TEnchantment);
begin end;

procedure TPlayerMagicControl.UnregisterEnchantment(Enchantment: TEnchantment);
begin end;

procedure TPlayerMagicControl.RegisterPowerSource(Source: TPowerSource);
begin end;

procedure TPlayerMagicControl.UnregisterPowerSource(Source: TPowerSource);
begin end;

procedure TPlayerMagicControl.CreateChangeMagicTE;
begin end;

procedure TPlayerMagicControl.ExecuteDispelEnchantment(A1: Integer);
begin end;

procedure TPlayerMagicControl.DispelEnchantment;
begin end;

procedure TPlayerMagicControl.ExecuteChangePowerSettings(A1: Integer);
begin end;

procedure TPlayerMagicControl.ChangePowerSettings(A1: Integer);
begin end;

procedure TPlayerMagicControl.ExecuteResearchSpell(A1: Integer);
begin end;

procedure TPlayerMagicControl.ResearchSpell(A1: Integer);
begin end;

procedure TPlayerMagicControl.AIRequestOverrideUpkeep(A1: Integer; A2: Integer);
begin end;

procedure TPlayerMagicControl.AIOverrideUpkeep(Priority, Amount: Integer);
begin end;

class function TChangePlayerMagicTE.ClassID: Integer;
begin Result := 0; end;

procedure TChangePlayerMagicTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TChangePlayerMagicTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

constructor TGlobalEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

function TGlobalEnchantment.AddRef: Integer;
begin Result := 0; end;

function TGlobalEnchantment.Release: Integer;
begin Result := 0; end;

function TGlobalEnchantment.GetAIUpkeepPriority: Integer;
begin Result := 0; end;

function TGlobalEnchantment.GetLocation: TXYL;
begin Result.XYL := 0; end;

procedure TGlobalEnchantment.CenterToLocation(A1: Integer; A2: Integer);
begin end;

function TGlobalEnchantment.GetName: string;
begin Result := ''; end;

procedure TGlobalEnchantment.GetUpkeep;
begin end;

function TGlobalEnchantment.VisibleForPlayer(Player: Shortint): Boolean;
begin Result := False; end;

procedure TGlobalEnchantment.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TGlobalEnchantment.Setup(A1: Integer; A2: Integer);
begin end;

procedure TGlobalEnchantment.CanActivate(A1: Integer; A2: Integer);
begin end;

procedure TGlobalEnchantment.Activate(A1: Byte);
begin end;

procedure TGlobalEnchantment.CanDeactivate(A1: Integer; A2: Integer);
begin end;

function TGlobalEnchantment.Deactivate(Player: Byte): Boolean;
begin Result := False; end;

procedure TGlobalEnchantment.CanCast;
begin end;

procedure TGlobalEnchantment.Cast(A1: Integer);
begin end;

procedure TGlobalEnchantment.CanDispel;
begin end;

procedure TGlobalEnchantment.Dispel(A1: Byte);
begin end;

procedure TGlobalEnchantment.CanRemove(A1: Byte; A2: Integer);
begin end;

procedure TGlobalEnchantment.Remove(A1: Byte);
begin end;

class function TGlobalEnchantmentEventLog.ClassID: Integer;
begin Result := 0; end;

procedure TGlobalEnchantmentEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TGlobalEnchantmentEventLog.GetLeftIcon: Integer;
begin Result := 0; end;

function TGlobalEnchantmentList.GetEnchantments(A1: Integer): TGlobalEnchantment;
begin Result := nil; end;

constructor TGlobalMagicControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TGlobalMagicControl.Destroy;
begin end;

procedure TGlobalMagicControl.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TGlobalMagicControl.IncDoubleSphereManaCount(A1: Integer);
begin end;

procedure TGlobalMagicControl.DecDoubleSphereManaCount(A1: Integer);
begin end;

function TGlobalMagicControl.GetSphereManaDoubled(A1: TMagicSphere): Boolean;
begin Result := False; end;

procedure TGlobalMagicControl.OutOfMana(A1: Byte; A2: Integer);
begin end;

procedure TGlobalMagicControl.RemovePlayerEnchantments(Player: Shortint);
begin end;

procedure TGlobalMagicControl.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TGlobalMagicControl.BeginUpdate;
begin end;

procedure TGlobalMagicControl.EndUpdate;
begin end;

procedure TGlobalMagicControl.TriggerChangedEvent;
begin end;

procedure TGlobalMagicControl.Update;
begin end;

procedure TGlobalMagicControl.GetEnchantmentUpkeep(A1: Integer);
begin end;

procedure TGlobalMagicControl.UpdateActiveEnchantments(A1: Integer; A2: Integer);
begin end;

function TGlobalMagicControl.IndexOfID(A1: Integer): Integer;
begin Result := 0; end;

procedure TGlobalMagicControl.ValidateEnchantmentID(A1: Integer);
begin end;

procedure TGlobalMagicControl.CreateChangeMagicTE;
begin end;

function TGlobalMagicControl.ExecuteDispelEnchantment(Player: Shortint; EnchantmentID: Integer): Boolean;
begin Result := False; end;

procedure TGlobalMagicControl.DispelEnchantment(A1: Integer; A2: Integer);
begin end;

procedure TGlobalMagicControl.ExecuteRemoveEnchantment(A1: Integer; A2: Integer);
begin end;

procedure TGlobalMagicControl.RemoveEnchantment(A1: Integer; A2: Integer);
begin end;

class function TChangeGlobalMagicTE.ClassID: Integer;
begin Result := 0; end;

procedure TChangeGlobalMagicTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TChangeGlobalMagicTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

{ Unnamed shared helper at $55771138; body remains for its owning worker. }
function RoadConstructionCost(Player: Shortint; Path: TMovepath; MovePoints: Integer): Integer;
begin Result := 0; end;

