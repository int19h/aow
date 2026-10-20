{ Engine's private list accessor is reached through its public property. }
function P4LevelCost(Costs: TIntegerList; Level: Integer): Integer;
begin
  Result := Costs[Level];
end;

{ P4 abilities and magic.
  Adjustable, duration and multilevel ability data; unit-enchantment ability data;
  the base spell, spell events/control/list/casters and power-source classes are
  recovered. Remaining draft bodies below are unchanged unless documented.
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
  TCombatOwnerReturnView = class(TEObject)
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
    procedure Slot94; virtual; abstract;
    procedure Slot98; virtual; abstract;
    procedure Slot9C; virtual; abstract;
    procedure SlotA0; virtual; abstract;
    procedure SlotA4; virtual; abstract;
    procedure SlotA8; virtual; abstract;
    procedure SlotAC; virtual; abstract;
    procedure SlotB0; virtual; abstract;
    procedure SlotB4; virtual; abstract;
    function GetAbilityOwner: TAbilityOwner; virtual; abstract;
  end;
  TAbilityOwnerP4 = class(TAbilityOwner)
    function DurationData(AbilityID: Integer): TDurationAbilityData;
  end;

const
  { The class-reference constant supplies the EAX return while the inherited
    AbilityDataClass declaration is still a procedure. }
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
  NotEnoughManaRStr = 'Not enough mana.';
  NotEnoughCastingPointsRStr = 'Not enough channeling points';
  P4SpellWardBlocksCastRStr = 'Spell Ward locks all global enchantments';
  P4ExternalPowerRStr = 'External';
  DurationDaysRStr = '(%s/%s days)';
  DurationCombatTurnRStr = '(%s/%s turns)';
  DurationEntireCombatRStr = '(combat only)';

procedure P4TranslateInto(const S: string; var Dest: string); assembler;
{ needs: P1 TranslateRStr has a string result at EDX; 5577C2D4. }
asm
  JMP TranslateRStr
end;

function P4TranslateRStr(const S: string): string; assembler;
{ needs: P1 TranslateRStr(const S: string): string; 55764EF6 returns a string. }
asm
  JMP TranslateRStr
end;

function P4Format(const S: string; const Args: array of const): string; assembler;
{ needs: P1 Format(const S: string; const Args: array of const): string;
  55764F04 has array high bound 1 in ECX and result pointer on stack. }
asm
  { Assembler functions with a stack result pointer receive an implicit EBP frame. }
  POP EBP
  JMP Format
end;

function TAbilityOwnerP4.DurationData(AbilityID: Integer): TDurationAbilityData;
assembler;
{ needs: P1 TAbilityOwner.GetAbilityData: TAbilityData; 55765044 tests EAX. }
asm
  JMP TAbilityOwner.GetAbilityData
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

function P4BaseAbilityName(Ability: TAbility; AbilityOwner: Integer): string; assembler;
{ needs: P1 TAbility.GetName string result in ECX at 55764E7C. }
asm
  JMP TAbility.GetName
end;

procedure TAdjustableAbility.GetAbilityType;
{ needs: P1 TAbility.GetAbilityType: TAbilityType (AL at 55764C70). }
asm
  MOV AL, [EAX].TAdjustableAbility.FAbilityType
end;

class function TDurationAbilityData.ClassID: Integer;
begin
  Result := $22002;
end;

procedure TDurationAbilityData.GetAbilityID;
{ needs: P1 TAbilityData.GetAbilityID: Integer (EAX at 55764C7C). }
asm
  MOVZX EAX, [EAX].TDurationAbilityData.FAbilityID
end;

procedure TDurationAbilityData.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(FDuration, 11);
  Stream.rwWord(FAbilityID, 12);
  Stream.rwByte(FPlayerIndex, 13);
  Stream.rwInteger(F_DurationAbilityData_10, 14);
end;

constructor TDurationAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
end;

procedure TDurationAbility.AbilityDataClass;
{ needs: P1 TAbility.AbilityDataClass: class of TAbilityData (EAX at 55764D04). }
asm
  MOV EAX, DWORD PTR [P4DurationDataClass]
end;

procedure TDurationAbility.GetTotalDuration;
{ needs: GetTotalDuration: Integer and matching P6 PassiveAb overrides. }
asm
  MOV EAX, 3
end;

procedure TDurationAbility.NewDay(A1: Integer);
begin
  if AoWHSMap.FDay = 1 then
    TAbilityOwner(A1).RemoveAbility(FAbilityID);
end;

procedure TDurationAbility.NewTurn(A1: Integer; A2: Integer);
{ needs: P1 TAbility.NewTurn(AbilityOwner: TAbilityOwner; PlayerIndex: ShortInt).
  Original 55764D33 saves ECX, EDX, EAX to EBX, ESI, EDI. Integer drafts require
  typed locals here; direct casts, reordered locals and absolute aliases differ. }
var
  PlayerIndex: ShortInt;
  AbilityOwner: TAbilityOwnerP4;
  Data: TDurationAbilityData;
begin
  PlayerIndex := ShortInt(A2);
  AbilityOwner := TAbilityOwnerP4(A1);
  if FDurationMode = dmDay then
  begin
    Data := AbilityOwner.DurationData(FAbilityID);
    if Data <> nil then
    begin
      if (Data.FDuration <> 0) and (PlayerIndex = Data.FPlayerIndex) then
      begin
        Dec(Data.FDuration);
        if Data.FDuration = 0 then
          AbilityOwner.RemoveAbility(FAbilityID);
      end;
    end
    else
      AbilityOwner.RemoveAbility(FAbilityID);
  end;
end;

procedure TDurationAbility.NewCombatTurn(A1: Integer; A2: Integer);
{ needs: P1 TAbility.NewCombatTurn(CombatObject: TCombatObject; PlayerIndex: ShortInt).
  Original 55764D8F saves ECX, EDX, EAX to EBX, ESI, EDI. Same local variants
  as NewTurn were tried; absolute aliases force an unwanted EBP frame. }
var
  PlayerIndex: ShortInt;
  CombatObject: TCombatOwnerReturnView;
  Data: TDurationAbilityData;
begin
  PlayerIndex := ShortInt(A2);
  CombatObject := TCombatOwnerReturnView(A1);
  if FDurationMode = dmCombatTurn then
  begin
    Data := TAbilityOwnerP4(CombatObject.GetAbilityOwner).DurationData(FAbilityID);
    if Data <> nil then
    begin
      if (Data.FDuration <> 0) and (PlayerIndex = Data.FPlayerIndex) then
      begin
        Dec(Data.FDuration);
        if Data.FDuration = 0 then
          CombatObject.GetAbilityOwner.RemoveAbility(FAbilityID);
      end;
    end
    else
      CombatObject.GetAbilityOwner.RemoveAbility(FAbilityID);
  end;
end;

procedure TDurationAbility.CombatDone(A1: Integer);
begin
  case FDurationMode of
    dmCombatTurn, dmEntireCombat:
      TCombatOwnerReturnView(A1).GetAbilityOwner.RemoveAbility(FAbilityID);
  end;
end;

procedure TDurationAbility.GetName(A1: Integer; A2: Integer);
{ needs: P1 TAbility.GetName(AbilityOwner: TAbilityOwner): string;
  A2 is the hidden string-result pointer in ECX at 55764E3E. }
begin
  if A1 <> 0 then
    case FDurationMode of
      dmDay:
        begin
          inherited GetName(A1, A2);
          if GetDuration(TAbilityOwner(A1)) <> 0 then
            P4LongString(Pointer(A2))^ := P4LongString(Pointer(A2))^ + ' ' +
              P4Format(P4TranslateRStr(DurationDaysRStr),
                [IntToStr(GetDuration(TAbilityOwner(A1))), IntToStr(TDurationReturnView(Self).GetTotalDuration)]);
        end;
      dmCombatTurn:
        begin
          P4LongString(Pointer(A2))^ := P4BaseAbilityName(Self, A1) + ' ' +
            P4Format(P4TranslateRStr(DurationCombatTurnRStr),
              [IntToStr(GetDuration(TAbilityOwner(A1))), IntToStr(TDurationReturnView(Self).GetTotalDuration)]);
        end;
      dmEntireCombat:
        begin
          P4LongString(Pointer(A2))^ := P4BaseAbilityName(Self, A1) + ' ' + P4TranslateRStr(DurationEntireCombatRStr);
        end;
      { Original leaves the caller's string untouched for dmNone and a nonnil owner. }
    end
  else
    inherited GetName(A1, A2);
end;

function TDurationAbility.GetDuration(AbilityOwner: TAbilityOwner): Byte;
{ 55765034 saves Self and AbilityOwner in EBX/ESI. The typed adapter, explicit
  locals, with, and inverted branch variants all omit those saves; a procedural
  cast adds an indirect call. Retain the straightforward body pending P1's API. }
var
  Data: TDurationAbilityData;
begin
  Data := TAbilityOwnerP4(AbilityOwner).DurationData(FAbilityID);
  if Data <> nil then
    Result := Data.FDuration
  else
    Result := 0;
end;

procedure TDurationAbility.Expand(A1: Integer; A2: Integer);
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

procedure TDurationAbility.Remove(A1: Integer; A2: Integer);
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

procedure TMultiLevelAbilityData.GetAbilityID;
{ needs: P1 TAbilityData.GetAbilityID returns Integer; 55765160 zero-extends $0E. }
asm
  MOVZX EAX, [EAX].TMultiLevelAbilityData.FLevelAbilityID
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

procedure TMultiLevelAbility.GetLevel(A1: Integer);
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

procedure TMultiLevelAbility.AbilityDataClass;
{ needs: P1 TAbility.AbilityDataClass returns a class reference; 55765228. }
asm
  MOV EAX, DWORD PTR [P4MultiLevelDataClass]
end;

procedure TMultiLevelAbility.GetLevelName(A1: Integer; A2: Integer);
begin
  P4LongString(Pointer(A2))^ := 'Unknown ' + IntToStr(A1);
end;

procedure TMultiLevelAbility.GetName(A1: Integer; A2: Integer);
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

procedure TMultiLevelAbility.ExpandName(A1: Integer; A2: Integer);
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

procedure TMultiLevelAbility.ExpandCost;
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

procedure TMultiLevelAbility.CanExpand(A1: Integer);
{ needs: P1 selection-types and inherent-level virtuals have results; 55765312/5576532E. }
asm
  PUSH EBX
  PUSH ESI
  MOV ESI, EDX
  MOV EBX, EAX
  MOV EAX, ESI
  MOV EDX, [EAX]
  CALL DWORD PTR [EDX + $8C]
  AND AX, [EBX].TAbility.F_Ability_20
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

procedure TMultiLevelAbility.GetSkillPoints(A1: Integer);
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

procedure TMultiLevelAbility.Expand(A1: Integer; A2: Integer);
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

procedure TMultiLevelAbility.Remove(A1: Integer; A2: Integer);
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

procedure TUnitEnchantmentAbilityData.GetAbilityID;
{ needs: P1 TAbilityData.GetAbilityID returns Integer; 557654A8 reads $0C. }
asm
  MOVZX EAX, [EAX].TUnitEnchantmentAbilityData.FEnchantmentAbilityID
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
begin end;

procedure TUnitEnchantmentAbility.GetAIUpkeepPriority(A1: Integer);
begin end;

procedure TUnitEnchantmentAbility.GetName(A1: Integer; A2: Integer);
begin end;

procedure TUnitEnchantmentAbility.GetSourceName(A1: Integer; A2: Integer);
begin end;

procedure TUnitEnchantmentAbility.AbilityDataClass;
begin end;

procedure TUnitEnchantmentAbility.CreateEnchantment;
begin end;

procedure TUnitEnchantmentAbility.Expand(A1: Integer; A2: Integer);
begin end;

procedure TUnitEnchantmentAbility.Remove(A1: Integer; A2: Integer);
begin end;

procedure TUnitEnchantmentAbility.GetDurationMode;
begin end;

procedure TUnitEnchantmentAbility.GetDuration(A1: Integer);
begin end;

procedure TUnitEnchantmentAbility.GetTotalDuration;
begin end;

procedure TUnitEnchantmentAbility.NewTurn(A1: Integer; A2: Integer);
begin end;

procedure TUnitEnchantmentAbility.NewCombatTurn(A1: Integer; A2: Integer);
begin end;

procedure TUnitEnchantmentAbility.CombatDone(A1: Integer);
begin end;

constructor TUnitEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

class function TUnitEnchantment.ClassID: Integer;
begin Result := 0; end;

procedure TUnitEnchantment.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TUnitEnchantment.GetName(A1: Integer);
begin end;

procedure TUnitEnchantment.GetAIUpkeepPriority;
begin end;

procedure TUnitEnchantment.GetBinding(A1: Integer);
begin end;

procedure TUnitEnchantment.Select;
begin end;

procedure TUnitEnchantment.GetLocation(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TUnitEnchantment.Dispel;
begin end;

constructor TCosmeticSurgeryEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

class function TCosmeticSurgeryEnchantment.ClassID: Integer;
begin Result := 0; end;

procedure TCosmeticSurgeryEnchantment.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TCosmeticSurgeryEnchantment.GetName(A1: Integer);
begin end;

constructor TCosmeticSurgeryAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TCosmeticSurgeryAbility.CreateEnchantment;
begin end;

constructor TEnhancementAbility.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TTransportAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TTransportAbility.GetLevelName(A1: Integer; A2: Integer);
begin end;

class function TLeadershipAbilityData.ClassID: Integer;
begin Result := 0; end;

procedure TLeadershipAbilityData.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

constructor TLeadershipAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TLeadershipAbility.AbilityDataClass;
begin end;

procedure TLeadershipAbility.GetLevel(A1: Integer);
begin end;

procedure TLeadershipAbility.GetAttack;
begin end;

procedure TLeadershipAbility.GetDefense;
begin end;

procedure TLeadershipAbility.SetExternalSource(A1: Integer; A2: Integer);
begin end;

procedure TLeadershipAbility.ResetExternalSource(A1: Integer);
begin end;

procedure TLeadershipAbility.GetSourceName(A1: Integer; A2: Integer);
begin end;

procedure TLeadershipAbility.GetInherent(A1: Integer);
begin end;

procedure TLeadershipAbility.CanExpand(A1: Integer);
begin end;

procedure TLeadershipAbility.GetLevelName(A1: Integer; A2: Integer);
begin end;

class function TStrikeCA.ClassID: Integer;
begin Result := 0; end;

procedure TStrikeCA.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TStrikeCA.Execute(A1: Integer; A2: Integer);
begin end;

procedure TStrikeCA.Play(A1: Integer);
begin end;

procedure TStrikeCA.Generate(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

constructor TStrikeAbility.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TStrikeAbility.Destroy;
begin end;

procedure TStrikeAbility.GetControlType;
begin end;

procedure TStrikeAbility.Remove(A1: Integer; A2: Integer);
begin end;

procedure TStrikeAbility.CanExecuteMelee(A1: Integer; A2: Integer);
begin end;

procedure TStrikeAbility.GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TStrikeAbility.GetDamageValue(A1: Integer; A2: Integer);
begin end;

procedure TStrikeAbility.GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TStrikeAbility.fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TStrikeAbility.GetCombatMode(A1: Integer);
begin end;

procedure TStrikeAbility.GetDamageTypes(A1: Integer);
begin end;

procedure TStrikeAbility.GetCombatInfo(A1: Integer; A2: Integer);
begin end;

procedure TStrikeAbility.fcExecuteCombatCommand(A1: Integer; A2: Integer);
begin end;

procedure TStrikeAbility.fcPrefetchCombatCommands(A1: Integer);
begin end;

constructor TStrikeEnhancementAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TStrikeEnhancementAbility.CanExpand(A1: Integer);
begin end;

constructor TMeleeRound.Create;
begin end;

destructor TMeleeRound.Destroy;
begin end;

procedure TMeleeRound.SetCapacity(A1: Integer);
begin end;

procedure TMeleeRound.SetCount(A1: Integer);
begin end;

procedure TMeleeRound.GetMeleeStrike(A1: Integer; A2: Integer);
begin end;

procedure TMeleeRound.Reset;
begin end;

procedure TMeleeRound.CalculateUnitStrikes(A1: Byte);
begin end;

procedure TMeleeRound.CalculateFreeUnitSwing(A1: Integer; A2: Integer);
begin end;

procedure TMeleeRound.CalculateUnit(A1: Integer; A2: Integer);
begin end;

procedure TMeleeRound.CalculateStrikes(A1: Byte);
begin end;

procedure TMeleeRound.Calculate(A1: Integer; A2: Integer);
begin end;

procedure TMeleeRound.CalculateSingleSide(A1: Integer; A2: Integer);
begin end;

procedure TMeleeRound.CreateStrikeCA(A1: Integer);
begin end;

procedure TMeleeRound.CalculateDV(A1: Integer; A2: Integer);
begin end;

procedure TMeleeRound.GetAttackerDV;
begin end;

procedure TMeleeRound.GetDefenderDV;
begin end;

constructor TTouchAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TTouchAbility.GetControlType;
begin end;

procedure TTouchAbility.GetTouchAttack(A1: Integer);
begin end;

procedure TTouchAbility.GetCombatInfo(A1: Integer; A2: Integer);
begin end;

procedure TTouchAbility.GetCombatMode(A1: Integer);
begin end;

procedure TTouchAbility.TouchRoleProbability(A1: Integer; A2: Integer);
begin end;

procedure TTouchAbility.CombatTouchRole(A1: Integer; A2: Integer);
begin end;

procedure TTouchAbility.CombatTouchRoleProbability(A1: Integer; A2: Integer);
begin end;

procedure TTouchAbility.CanTouch(A1: Integer; A2: Integer);
begin end;

procedure TTouchAbility.CanTouchUnit(A1: Integer; A2: Integer);
begin end;

procedure TTouchAbility.fcValidateMoveOutsideWall(A1: Integer; A2: Integer);
begin end;

procedure TTouchAbility.fcPrefetchCombatCommands(A1: Integer);
begin end;

constructor TWallCrushingAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TWallCrushingAbility.GetDamageValue(A1: Integer; A2: Integer);
begin end;

procedure TWallCrushingAbility.GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TWallCrushingAbility.fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TWallCrushingAbility.tcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TWallCrushingAbility.GetCombatInfo(A1: Integer; A2: Integer);
begin end;

procedure TWallCrushingAbility.GetWallCombatFeatures(A1: Integer);
begin end;

procedure TWallCrushingAbility.fcExecuteCombatCommand(A1: Integer; A2: Integer);
begin end;

procedure TWallCrushingAbility.GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TWallCrushingAbility.CanTouch(A1: Integer; A2: Integer);
begin end;

class function TSelfDestructCA.ClassID: Integer;
begin Result := 0; end;

procedure TSelfDestructCA.Execute(A1: Integer; A2: Integer);
begin end;

procedure TSelfDestructCA.ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

constructor TSelfDestructAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TSelfDestructAbility.GetDamageValue(A1: Integer; A2: Integer);
begin end;

procedure TSelfDestructAbility.GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TSelfDestructAbility.fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TSelfDestructAbility.GetCombatInfo(A1: Integer; A2: Integer);
begin end;

procedure TSelfDestructAbility.GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TSelfDestructAbility.GetWallCombatFeatures(A1: Integer);
begin end;

procedure TSelfDestructAbility.CreateSelfDestructCA(A1: Integer; A2: Integer);
begin end;

procedure TSelfDestructAbility.fcExecuteCombatCommand(A1: Integer; A2: Integer);
begin end;

procedure TSelfDestructAbility.CanTouch(A1: Integer; A2: Integer);
begin end;

procedure TSelfDestructAbility.CanTouchUnit(A1: Integer; A2: Integer);
begin end;

constructor TRoundAttackAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TRoundAttackAbility.GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TRoundAttackAbility.GetDamageValue(A1: Integer; A2: Integer);
begin end;

procedure TRoundAttackAbility.GetCombatInfo(A1: Integer; A2: Integer);
begin end;

procedure TRoundAttackAbility.GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TRoundAttackAbility.fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TRoundAttackAbility.tcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TRoundAttackAbility.fcExecuteCombatCommand(A1: Integer; A2: Integer);
begin end;

class function TPossessCA.ClassID: Integer;
begin Result := 0; end;

procedure TPossessCA.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TPossessCA.Initialize(A1: Byte; A2: Byte; A3: Integer);
begin end;

procedure TPossessCA.Execute(A1: Integer; A2: Integer);
begin end;

procedure TPossessCA.ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

procedure TPossessCA.Play(A1: Integer);
begin end;

class function TPossessedAbilityData.ClassID: Integer;
begin Result := 0; end;

procedure TPossessedAbilityData.GetAbilityID;
begin end;

procedure TPossessedAbilityData.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

constructor TPossessedAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TPossessedAbility.CombatObjectDestroyed(A1: Integer);
begin end;

procedure TPossessedAbility.AbilityDataClass;
begin end;

procedure TPossessedAbility.Expand(A1: Integer; A2: Integer);
begin end;

procedure TPossessedAbility.Remove(A1: Integer; A2: Integer);
begin end;

constructor TPossessAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TPossessAbility.GetTouchAttack(A1: Integer);
begin end;

procedure TPossessAbility.CreatePossessCA(A1: Integer; A2: Integer);
begin end;

procedure TPossessAbility.CanTouch(A1: Integer; A2: Integer);
begin end;

procedure TPossessAbility.CanTouchUnit(A1: Integer; A2: Integer);
begin end;

procedure TPossessAbility.GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TPossessAbility.GetDamageValue(A1: Integer; A2: Integer);
begin end;

procedure TPossessAbility.GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TPossessAbility.fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TPossessAbility.fcExecuteCombatCommand(A1: Integer; A2: Integer);
begin end;

class function TWebCA.ClassID: Integer;
begin Result := 0; end;

procedure TWebCA.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TWebCA.Initialize(A1: Byte; A2: Byte; A3: Integer);
begin end;

procedure TWebCA.Execute(A1: Integer; A2: Integer);
begin end;

procedure TWebCA.ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

procedure TWebCA.Play(A1: Integer);
begin end;

constructor TWebAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TWebAbility.GetTouchAttack(A1: Integer);
begin end;

procedure TWebAbility.CreateWebCA(A1: Integer; A2: Integer);
begin end;

procedure TWebAbility.CanTouch(A1: Integer; A2: Integer);
begin end;

procedure TWebAbility.GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TWebAbility.GetDamageValue(A1: Integer; A2: Integer);
begin end;

procedure TWebAbility.GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TWebAbility.fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TWebAbility.fcExecuteCombatCommand(A1: Integer; A2: Integer);
begin end;

class function TEntangleCA.ClassID: Integer;
begin Result := 0; end;

procedure TEntangleCA.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TEntangleCA.Initialize(A1: Byte; A2: Byte; A3: Integer);
begin end;

procedure TEntangleCA.Execute(A1: Integer; A2: Integer);
begin end;

procedure TEntangleCA.ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

procedure TEntangleCA.Play(A1: Integer);
begin end;

constructor TEntangleAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TEntangleAbility.GetTouchAttack(A1: Integer);
begin end;

procedure TEntangleAbility.CreateEntangleCA(A1: Integer; A2: Integer);
begin end;

procedure TEntangleAbility.CanTouch(A1: Integer; A2: Integer);
begin end;

procedure TEntangleAbility.GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TEntangleAbility.GetDamageValue(A1: Integer; A2: Integer);
begin end;

procedure TEntangleAbility.GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TEntangleAbility.fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TEntangleAbility.fcExecuteCombatCommand(A1: Integer; A2: Integer);
begin end;

class function TTurnUndeadCA.ClassID: Integer;
begin Result := 0; end;

procedure TTurnUndeadCA.GetSuccessfull;
begin end;

procedure TTurnUndeadCA.Execute(A1: Integer; A2: Integer);
begin end;

procedure TTurnUndeadCA.ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

procedure TTurnUndeadCA.Play(A1: Integer);
begin end;

constructor TTurnUndeadAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TTurnUndeadAbility.CanTouchUnit(A1: Integer; A2: Integer);
begin end;

procedure TTurnUndeadAbility.CanTouch(A1: Integer; A2: Integer);
begin end;

procedure TTurnUndeadAbility.GetLevel(A1: Integer);
begin end;

procedure TTurnUndeadAbility.AbilityDataClass;
begin end;

procedure TTurnUndeadAbility.GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TTurnUndeadAbility.GetLevelName(A1: Integer; A2: Integer);
begin end;

procedure TTurnUndeadAbility.GetName(A1: Integer; A2: Integer);
begin end;

procedure TTurnUndeadAbility.ExpandName(A1: Integer; A2: Integer);
begin end;

procedure TTurnUndeadAbility.ExpandCost;
begin end;

procedure TTurnUndeadAbility.CanExpand(A1: Integer);
begin end;

procedure TTurnUndeadAbility.GetSkillPoints(A1: Integer);
begin end;

procedure TTurnUndeadAbility.Expand(A1: Integer; A2: Integer);
begin end;

procedure TTurnUndeadAbility.Remove(A1: Integer; A2: Integer);
begin end;

procedure TTurnUndeadAbility.GetTouchAttack(A1: Integer);
begin end;

procedure TTurnUndeadAbility.GetTurnUndeadDamage(A1: Integer);
begin end;

procedure TTurnUndeadAbility.GetCombatInfo(A1: Integer; A2: Integer);
begin end;

procedure TTurnUndeadAbility.GetDamageValue(A1: Integer; A2: Integer);
begin end;

procedure TTurnUndeadAbility.GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TTurnUndeadAbility.fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TTurnUndeadAbility.CreateTurnUndeadCA(A1: Integer; A2: Integer);
begin end;

procedure TTurnUndeadAbility.fcExecuteCombatCommand(A1: Integer; A2: Integer);
begin end;

class function TInvokeDeathCA.ClassID: Integer;
begin Result := 0; end;

procedure TInvokeDeathCA.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TInvokeDeathCA.ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

procedure TInvokeDeathCA.Play(A1: Integer);
begin end;

procedure TInvokeDeathCA.Execute(A1: Integer; A2: Integer);
begin end;

procedure TInvokeDeathCA.Initialize(A1: Byte; A2: Byte; A3: Integer);
begin end;

constructor TInvokeDeathAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TInvokeDeathAbility.GetCombatInfo(A1: Integer; A2: Integer);
begin end;

procedure TInvokeDeathAbility.GetTouchAttack(A1: Integer);
begin end;

procedure TInvokeDeathAbility.GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TInvokeDeathAbility.GetDamageValue(A1: Integer; A2: Integer);
begin end;

procedure TInvokeDeathAbility.GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TInvokeDeathAbility.fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TInvokeDeathAbility.CreateCA(A1: Integer; A2: Integer);
begin end;

procedure TInvokeDeathAbility.fcExecuteCombatCommand(A1: Integer; A2: Integer);
begin end;

procedure TInvokeDeathAbility.CanTouchUnit(A1: Integer; A2: Integer);
begin end;

procedure TInvokeDeathAbility.CanTouch(A1: Integer; A2: Integer);
begin end;

class function THealingCA.ClassID: Integer;
begin Result := 0; end;

procedure THealingCA.Initialize(A1: Byte; A2: Byte);
begin end;

procedure THealingCA.Execute(A1: Integer; A2: Integer);
begin end;

procedure THealingCA.ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

procedure THealingCA.Play(A1: Integer);
begin end;

class function THealingAbilityData.ClassID: Integer;
begin Result := 0; end;

procedure THealingAbilityData.GetAbilityID;
begin end;

procedure THealingAbilityData.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

constructor THealingAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure THealingAbility.GetControlType;
begin end;

procedure THealingAbility.SetEnabled(A1: Integer; A2: Integer);
begin end;

procedure THealingAbility.GetEnabled(A1: Integer);
begin end;

procedure THealingAbility.NewTurn(A1: Integer; A2: Integer);
begin end;

procedure THealingAbility.AbilityDataClass;
begin end;

procedure THealingAbility.GetName(A1: Integer; A2: Integer);
begin end;

procedure THealingAbility.Remove(A1: Integer; A2: Integer);
begin end;

procedure THealingAbility.GetHealHitPoints(A1: Integer);
begin end;

procedure THealingAbility.CreateHealingCA(A1: Integer; A2: Integer);
begin end;

procedure THealingAbility.CanTouchUnit(A1: Integer; A2: Integer);
begin end;

procedure THealingAbility.CanTouch(A1: Integer; A2: Integer);
begin end;

procedure THealingAbility.GetCombatInfo(A1: Integer; A2: Integer);
begin end;

procedure THealingAbility.GetDamageValue(A1: Integer; A2: Integer);
begin end;

procedure THealingAbility.GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure THealingAbility.fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure THealingAbility.HealUnit(A1: Integer);
begin end;

procedure THealingAbility.fcExecuteCombatCommand(A1: Integer; A2: Integer);
begin end;

procedure THealingAbility.fcPrefetchCombatCommands(A1: Integer);
begin end;

procedure THealingAbility.Activate(A1: Integer; A2: Integer);
begin end;

class function THealingTE.ClassID: Integer;
begin Result := 0; end;

procedure THealingTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function THealingTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure THealingUnitSelector.CanSelectUnit(A1: Integer);
begin end;

procedure THealingUnitSelector.Select;
begin end;

constructor TDispelMagicCA.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TDispelMagicCA.Destroy;
begin end;

procedure TDispelMagicCA.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TDispelMagicCA.Execute(A1: Integer; A2: Integer);
begin end;

procedure TDispelMagicCA.ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

procedure TDispelMagicCA.Play(A1: Integer);
begin end;

procedure TDispelMagicCA.Generate(A1: Integer; A2: Integer; A3: Integer);
begin end;

class function TDispelMagicAbilityCA.ClassID: Integer;
begin Result := 0; end;

procedure TDispelMagicAbilityCA.Execute(A1: Integer; A2: Integer);
begin end;

class function TDispelMagicAbilityData.ClassID: Integer;
begin Result := 0; end;

procedure TDispelMagicAbilityData.GetAbilityID;
begin end;

procedure TDispelMagicAbilityData.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

constructor TDispelMagicAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TDispelMagicAbility.GetControlType;
begin end;

procedure TDispelMagicAbility.SetEnabled(A1: Integer; A2: Integer);
begin end;

procedure TDispelMagicAbility.GetEnabled(A1: Integer);
begin end;

procedure TDispelMagicAbility.GetCombatInfo(A1: Integer; A2: Integer);
begin end;

procedure TDispelMagicAbility.GetDispelMana(A1: Integer);
begin end;

procedure TDispelMagicAbility.NewTurn(A1: Integer; A2: Integer);
begin end;

procedure TDispelMagicAbility.AbilityDataClass;
begin end;

procedure TDispelMagicAbility.GetLevel(A1: Integer);
begin end;

procedure TDispelMagicAbility.GetLevelName(A1: Integer; A2: Integer);
begin end;

procedure TDispelMagicAbility.ExpandName(A1: Integer; A2: Integer);
begin end;

procedure TDispelMagicAbility.GetName(A1: Integer; A2: Integer);
begin end;

procedure TDispelMagicAbility.ExpandCost;
begin end;

procedure TDispelMagicAbility.CanExpand(A1: Integer);
begin end;

procedure TDispelMagicAbility.GetSkillPoints(A1: Integer);
begin end;

procedure TDispelMagicAbility.Expand(A1: Integer; A2: Integer);
begin end;

procedure TDispelMagicAbility.Remove(A1: Integer; A2: Integer);
begin end;

procedure TDispelMagicAbility.CanTouchUnit(A1: Integer; A2: Integer);
begin end;

procedure TDispelMagicAbility.CanTouch(A1: Integer; A2: Integer);
begin end;

procedure TDispelMagicAbility.GetDamageValue(A1: Integer; A2: Integer);
begin end;

procedure TDispelMagicAbility.GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TDispelMagicAbility.fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TDispelMagicAbility.fcExecuteCombatCommand(A1: Integer; A2: Integer);
begin end;

procedure TDispelMagicAbility.fcPrefetchCombatCommands(A1: Integer);
begin end;

procedure TDispelMagicAbility.CreateCA(A1: Integer; A2: Integer);
begin end;

procedure TDispelMagicAbility.Activate(A1: Integer; A2: Integer);
begin end;

class function TDispelMagicAbilityTE.ClassID: Integer;
begin Result := 0; end;

procedure TDispelMagicAbilityTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TDispelMagicAbilityTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TDispelMagicAbilityUnitSelector.CanSelectUnit(A1: Integer);
begin end;

procedure TDispelMagicAbilityUnitSelector.Select;
begin end;

constructor TSpellCastingAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TSpellCastingAbility.GetLevelName(A1: Integer; A2: Integer);
begin end;

procedure TSpellCastingAbility.GetControlType;
begin end;

procedure TSpellCastingAbility.Expand(A1: Integer; A2: Integer);
begin end;

procedure TSpellCastingAbility.Remove(A1: Integer; A2: Integer);
begin end;

procedure TSpellCastingAbility.CanActivate(A1: Integer; A2: Integer);
begin end;

procedure TSpellCastingAbility.fcExecuteCombatCommand(A1: Integer; A2: Integer);
begin end;

procedure TSpellCastingAbility.CanCastBreachWallSpell(A1: Integer);
begin end;

procedure TSpellCastingAbility.AICanCastCombatSpell(A1: Integer);
begin end;

procedure TSpellCastingAbility.fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TSpellCastingAbility.tcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TSpellCastingAbility.fcPrefetchCombatCommands(A1: Integer);
begin end;

class function TRangedAttackCA.ClassID: Integer;
begin Result := 0; end;

procedure TRangedAttackCA.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TRangedAttackCA.ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

procedure TRangedAttackCA.GetName(A1: Integer);
begin end;

procedure TRangedAttackCA.Play(A1: Integer);
begin end;

constructor TRangedAttackAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TRangedAttackAbility.GetControlType;
begin end;

procedure TRangedAttackAbility.GetRangeRA;
begin end;

procedure TRangedAttackAbility.GetDamageRA(A1: Integer);
begin end;

procedure TRangedAttackAbility.GetAttackRA(A1: Integer);
begin end;

procedure TRangedAttackAbility.GetAttackRepeatRA;
begin end;

procedure TRangedAttackAbility.GetDamageTypesRA;
begin end;

procedure TRangedAttackAbility.GetCombatMode(A1: Integer);
begin end;

procedure TRangedAttackAbility.GetWallCombatFeatures(A1: Integer);
begin end;

procedure TRangedAttackAbility.GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TRangedAttackAbility.GetDamageValue(A1: Integer; A2: Integer);
begin end;

procedure TRangedAttackAbility.GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TRangedAttackAbility.fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TRangedAttackAbility.GetCombatInfo(A1: Integer; A2: Integer);
begin end;

procedure TRangedAttackAbility.CreateRangedAttackCA(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TRangedAttackAbility.fcExecuteCombatCommand(A1: Integer; A2: Integer);
begin end;

procedure TRangedAttackAbility.fcPrefetchCombatCommands(A1: Integer);
begin end;

procedure TRangedAttackAbility.fcValidRoundDistance(A1: Integer; A2: Integer);
begin end;

constructor TBoltsAbility.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TBreathAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TBreathAbility.GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TBreathAbility.fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TBreathAbility.fcExecuteCombatCommand(A1: Integer; A2: Integer);
begin end;

procedure TBreathAbility.tcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer);
begin end;

constructor TFlameThrowingAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TFlameThrowingAbility.GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer);
begin end;

constructor TCommandAbilityData.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TCommandAbilityData.Destroy;
begin end;

class function TCommandAbilityData.ClassID: Integer;
begin Result := 0; end;

procedure TCommandAbilityData.GetAbilityID;
begin end;

procedure TCommandAbilityData.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TCommandAbilityData.CommandingTargetPriority(A1: Integer; A2: Integer);
begin end;

procedure TCommandAbilityData.CommandingTargetStrength(A1: Integer; A2: Integer);
begin end;

class function TCommandedAbilityData.ClassID: Integer;
begin Result := 0; end;

procedure TCommandedAbilityData.GetAbilityID;
begin end;

procedure TCommandedAbilityData.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

constructor TCommandedAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TCommandedAbility.AbilityDataClass;
begin end;

procedure TCommandedAbility.Remove(A1: Integer; A2: Integer);
begin end;

procedure TCommandedAbility.CombatDone(A1: Integer);
begin end;

procedure TCommandedAbility.CombatObjectDestroyed(A1: Integer);
begin end;

class function TCommandCA.ClassID: Integer;
begin Result := 0; end;

procedure TCommandCA.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TCommandCA.Initialize(A1: Byte; A2: Byte; A3: Integer);
begin end;

procedure TCommandCA.ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

procedure TCommandCA.Execute(A1: Integer; A2: Integer);
begin end;

procedure TCommandCA.Play(A1: Integer);
begin end;

constructor TCommandAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TCommandAbility.AbilityDataClass;
begin end;

procedure TCommandAbility.Remove(A1: Integer; A2: Integer);
begin end;

procedure TCommandAbility.CombatDone(A1: Integer);
begin end;

procedure TCommandAbility.CombatObjectDestroyed(A1: Integer);
begin end;

procedure TCommandAbility.Command(A1: Integer; A2: Integer);
begin end;

procedure TCommandAbility.Uncommand(A1: Integer);
begin end;

procedure TCommandAbility.ResetCommandedUnits(A1: Integer; A2: Integer);
begin end;

procedure TCommandAbility.CanTouch(A1: Integer; A2: Integer);
begin end;

procedure TCommandAbility.CanTouchUnit(A1: Integer; A2: Integer);
begin end;

procedure TCommandAbility.GetAbilityType;
begin end;

procedure TCommandAbility.GetDamageValue(A1: Integer; A2: Integer);
begin end;

procedure TCommandAbility.GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TCommandAbility.GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TCommandAbility.fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TCommandAbility.CreateCommandCA(A1: Integer; A2: Integer);
begin end;

procedure TCommandAbility.fcExecuteCombatCommand(A1: Integer; A2: Integer);
begin end;

procedure TCommandAbility.fcPrefetchCombatCommands(A1: Integer);
begin end;

constructor TDominatedAbility.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TDominateAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TDominateAbility.GetTouchAttack(A1: Integer);
begin end;

constructor TCharmedAbility.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TCharmAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TCharmAbility.GetTouchAttack(A1: Integer);
begin end;

procedure TCharmAbility.CanTouchUnit(A1: Integer; A2: Integer);
begin end;

procedure TCharmAbility.CanTouch(A1: Integer; A2: Integer);
begin end;

constructor TSeducedAbility.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TSeduceAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TSeduceAbility.GetTouchAttack(A1: Integer);
begin end;

procedure TSeduceAbility.CanTouchUnit(A1: Integer; A2: Integer);
begin end;

procedure TSeduceAbility.CanTouch(A1: Integer; A2: Integer);
begin end;

procedure TRebuildConstructionControl.ID;
begin end;

procedure TRebuildConstructionControl.GetInfo(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TRebuildConstructionControl.CanConstruct(A1: Integer; A2: Integer);
begin end;

procedure TRebuildConstructionControl.Construct(A1: Integer);
begin end;

constructor TBuildRoadsControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TBuildRoadsControl.Destroy;
begin end;

procedure TBuildRoadsControl.ID;
begin end;

procedure TBuildRoadsControl.GetInfo(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TBuildRoadsControl.CanConstruct(A1: Integer; A2: Integer);
begin end;

procedure TBuildRoadsControl.Construct(A1: Integer);
begin end;

procedure TConstructionControl.GetInfo(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TConstructionControl.CanConstruct(A1: Integer; A2: Integer);
begin end;

procedure TConstructionControl.Construct(A1: Integer);
begin end;

procedure TConstructionControl.ID;
begin end;

procedure TConstructionControlList.GetConstructionControl(A1: Integer);
begin end;

procedure TConstructionControlList.FindID(A1: Integer);
begin end;

constructor TConstructAbility.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TConstructAbility.Destroy;
begin end;

procedure TConstructAbility.GetControlType;
begin end;

procedure TConstructAbility.CanActivate(A1: Integer; A2: Integer);
begin end;

procedure TConstructAbility.RegisterConstructionControl(A1: Integer);
begin end;

function TAbilityPlugIn.Name: string;
begin Result := ''; end;

function TAbilityPlugIn.Initialize(AEngine: Engine.TEngine): Boolean;
begin Result := False; end;

function TAbilityPlugIn.Finalize(AEngine: Engine.TEngine): Boolean;
begin Result := False; end;

procedure TSpellCC.GetName(A1: Integer);
begin end;

constructor TSpell.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellText := TStringList.Create;
  FCastSounds := TSFXLibrary.Create(nil);
  FCastImages := TImageSequenceList.Create(AoWHSSet.ImageLibraryManager, nil);
  F_Spell_18 := 1;
  FSpellControlTypes := [sctGlobal];
end;

destructor TSpell.Destroy;
begin
  FCastSounds.Free;
  FCastImages.Free;
  FSpellText.Free;
  inherited Destroy;
end;

procedure TSpell.GetEnabled;
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
  Stream.rwInteger(F_Spell_1C, 14);
  Stream.rwInteger(F_Spell_18, 15);
  Stream.rwData(FMagicSphere, 1, 16);
  Stream.rwByte(FSpellLevel, 17);
end;

procedure TSpell.CanActivate(A1: Integer; A2: Integer);
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

procedure TSpell.Activate(A1: Integer; A2: Integer);
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

procedure TSpell.CanActivateCombat(A1: Integer; A2: Integer);
asm
  MOV EAX, [AoWHSMap]
  CMP DWORD PTR [EAX + $120], 0
  SETNE AL
end;

procedure TSpell.ActivateCombat(A1: Integer);
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

procedure TSpell.CreateCA(A1: Integer; A2: Integer; A3: Integer);
asm
  XOR EAX, EAX
end;

procedure TSpell.GetCombatInfo(A1: Integer; A2: Integer);
{ ECX is a var parameter pointing to the eight-byte combat-info record.
  Preserve this ABI while unmarked external overrides still use Integer drafts. }
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

procedure TSpell.GetCombatDamageValue(A1: Integer; A2: Integer);
asm
  XOR EAX, EAX
end;

procedure TSpell.GetCombatDamageValueEx(A1: Integer; A2: Integer; A3: Integer);
begin
  with PP4DamageValue(Pointer(A3))^ do
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
      if TObject(Source.F_CombatObject_08) is TFastCombat then
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

procedure TSpell.PlayDefaultCastEffects(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
{ Byte player/X/Y/Layer ABI is retained until UnitSpells' unmarked overrides
  can be updated. Unmarked P1 map fields and Animation declarations stay intact. }
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

procedure TSpell.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
asm
  XOR EAX, EAX
end;

procedure TSpell.fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin
  FillChar(Pointer(A4)^, 20, 0);
end;

procedure TSpell.fcPrefetchCombatCommands(A1: Integer);
begin end;

procedure TSpell.fcExecuteCombatCommand(A1: Integer; A2: Integer);
asm
  XOR EAX, EAX
end;

procedure TSpell.tcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer);
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

procedure TSpell.CreateCastSpellAction;
asm
  XOR ECX, ECX
  MOV DL, 1
  MOV EAX, [P4CastSpellActionClass]
  CALL TEObject.Create
end;

procedure TSpell.SetupCastSpellAction(A1: Integer; A2: Integer);
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
    ShortInt(Source.FPlayer)).F_Player_8C);
  if not TPlayerMagicControl(P4GetPlayer(TPlayerList(AoWHSMap.FPlayers),
    ShortInt(Source.FPlayer)).FMagicControl).GetCheatEnabled then
    Result := P4RequestBudget(Manager, 0, Budget, 0, Mana, Manager.F_AIBudgetManager_38, 1)
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
      ShortInt(Source.FPlayer)).F_Player_8C);
    if not TPlayerMagicControl(P4GetPlayer(TPlayerList(AoWHSMap.FPlayers),
      ShortInt(Source.FPlayer)).FMagicControl).GetCheatEnabled then
      Result := P4BudgetMade(Manager, 0, Budget, 0, Mana, Manager.F_AIBudgetManager_38, 2)
    else
      Result := True;
  end
  else
    Result := False;
end;

procedure TSpell.AIPrefetchCastSpellActions(A1: Integer; A2: Integer);
begin end;

procedure TSpell.AIExecuteCastSpellAction(A1: Integer);
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

procedure TSpellTE.Validate(A1: Integer);
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

procedure TSpellTE.Process(A1: Integer; A2: Integer);
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
  Control := TUnitControlCallViewP4(AoWHSMap.F_AoWHSMap_FC);
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

procedure TSpellCaster.CanCast(A1: Integer);
{ The inherited draft's A1 is unused; AL reports whether the source still exists. }
asm
  MOV EDX, [AoWHSMap]
  MOV EDX, [EDX + $FC]
  MOV EAX, [EAX].TSpellCaster.FCasterSourceID
  XCHG EDX, EAX
  CALL TUnitControl.FindUnit
  TEST EAX, EAX
  SETNE AL
end;

procedure TSpellCaster.Cast;
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
begin Result := 0; end;

function TSpellCastEventLog.Execute(Mode: Integer; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
begin end;

procedure TSpellCastEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TSpellCastEventLog.ViewLocation(A1: Integer; A2: Integer);
begin end;

procedure TSpellCastEventLog.GetText(A1: Integer);
begin end;

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

procedure TUnitSpellCaster.CanCast(A1: Integer);
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

procedure TUnitSpellCaster.Cast;
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
begin Result := 0; end;

procedure TUnitSpellCA.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TUnitSpellCA.Execute(A1: Integer; A2: Integer);
begin end;

procedure TUnitSpellCA.Play(A1: Integer);
begin end;

constructor TUnitSpellTE.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TUnitSpellTE.Destroy;
begin end;

class function TUnitSpellTE.ClassID: Integer;
begin Result := 0; end;

procedure TUnitSpellTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TUnitSpellTE.Initialize(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TUnitSpellTE.Validate(A1: Integer);
begin end;

procedure TUnitSpellTE.Process(A1: Integer; A2: Integer);
begin end;

constructor TUnitSpell.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TUnitSpell.GetCombatInfo(A1: Integer; A2: Integer);
begin end;

procedure TUnitSpell.ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TUnitSpell.ValidTargetUnit(A1: Integer; A2: Integer);
begin end;

procedure TUnitSpell.ValidateUnitSelection(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TUnitSpell.SetupUSC(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TUnitSpell.CastSpell(A1: Integer; A2: Integer);
begin end;

procedure TUnitSpell.OnValidateTarget(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TUnitSpell.OnTargetSelectionChange(A1: Integer; A2: Integer);
begin end;

procedure TUnitSpell.ResetTargetSelection;
begin end;

procedure TUnitSpell.SetupTargetSelection(A1: Integer; A2: Integer);
begin end;

procedure TUnitSpell.ValidTargetParty(A1: Integer; A2: Integer);
begin end;

procedure TUnitSpell.TargetPartySelected(A1: Integer; A2: Integer);
begin end;

procedure TUnitSpell.Activate(A1: Integer; A2: Integer);
begin end;

procedure TUnitSpell.CanActivateCombat(A1: Integer; A2: Integer);
begin end;

procedure TUnitSpell.CreateCA(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TUnitSpell.CreateCAEx(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TUnitSpell.ExecuteCA(A1: Integer; A2: Integer);
begin end;

procedure TUnitSpell.AIRetrieveOptimalTargetUnit(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TUnitSpell.AIPrefetchCastSpellActions(A1: Integer; A2: Integer);
begin end;

procedure TUnitSpell.AIExecuteCastSpellAction(A1: Integer);
begin end;

procedure TResearchSpellAIPA.Priority;
begin end;

procedure TResearchSpellAIPA.Process(A1: Integer; A2: Integer);
begin end;

procedure TAICastSpellActionList.GetCastSpellActions(A1: Integer);
begin end;

procedure TAICastSpellActionList.SortOnPriority;
begin end;

constructor TCastSpellAIPA.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TCastSpellAIPA.Destroy;
begin end;

procedure TCastSpellAIPA.Priority;
begin end;

procedure TCastSpellAIPA.Activate(A1: Integer; A2: Integer);
begin end;

procedure TCastSpellAIPA.PrefetchCastSpellActions(A1: Integer);
begin end;

procedure TCastSpellAIPA.CastingHeroesMax;
begin end;

procedure TCastSpellAIPA.ProcessStates;
begin end;

procedure TCastSpellAIPA.Process(A1: Integer; A2: Integer);
begin end;

constructor TEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TEnchantment.GetName(A1: Integer);
begin end;

procedure TEnchantment.GetBinding(A1: Integer);
begin end;

procedure TEnchantment.GetLocation(A1: Integer; A2: Integer; A3: Integer);
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

procedure TEnchantment.Dispel;
begin end;

procedure TEnchantment.DispelChance(A1: Integer);
begin end;

procedure TEnchantment.GetAIUpkeepPriority;
begin end;

procedure TEnchantmentList.GetEnchantments(A1: Integer);
begin end;

procedure TEnchantmentList.IndexOfID(A1: Integer);
begin end;

procedure TEnchantmentList.FindID;
begin end;

procedure TPowerSource.Name(A1: Integer);
begin
  P4LongString(Pointer(A1))^ := '';
end;

procedure TPowerSource.Power;
asm
  XOR EAX, EAX
end;

procedure TPowerSource.GetLocation(A1: Integer; A2: Integer; A3: Integer);
begin
  P4ShortInt(Pointer(A1))^ := -1;
  P4ShortInt(Pointer(A2))^ := -1;
  P4ShortInt(Pointer(A3))^ := -1;
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

procedure TPowerSource.Select(A1: Integer; A2: Integer);
begin end;

procedure TPowerSourceList.GetItems(A1: Integer);
asm
  MOV EAX, [EAX + 8]
  MOV EAX, [EAX + 4]
  MOV EAX, [EAX + EDX * 4]
end;

procedure TExternalPowerSource.Name(A1: Integer);
begin
  P4TranslateInto(P4ExternalPowerRStr, P4LongString(Pointer(A1))^);
end;

procedure TExternalPowerSource.Power;
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

procedure TPlayerMagicEventLog.ViewLocation(A1: Integer; A2: Integer);
begin end;

function TPlayerMagicEventLog.Execute(Mode: Integer; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
begin end;

procedure TPlayerMagicEventLog.GetText(A1: Integer);
begin end;

constructor TPlayerMagicControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TPlayerMagicControl.Destroy;
begin end;

procedure TPlayerMagicControl.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TPlayerMagicControl.GetCheatEnabled: Boolean;
begin
  if TPlayer(F_PlayerMagicControl_10).FPlayerType = ptHuman then
    Result := Boolean(F_PlayerMagicControl_0C)
  else
    Result := False;
end;

procedure TPlayerMagicControl.SetActiveEnchantments(A1: Byte; A2: Integer);
begin end;

procedure TPlayerMagicControl.UpdateEnemyEnchantments;
begin end;

procedure TPlayerMagicControl.GetManaIncome;
begin end;

procedure TPlayerMagicControl.GetManaUpkeep;
begin end;

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

procedure TPlayerMagicControl.ListResearchSpells(A1: Integer; A2: Byte);
begin end;

procedure TPlayerMagicControl.ListSpells(A1: Integer; A2: Byte);
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

procedure TPlayerMagicControl.AIOverrideUpkeep(A1: Integer; A2: Integer);
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

procedure TGlobalEnchantment.GetAIUpkeepPriority;
begin end;

procedure TGlobalEnchantment.GetLocation(A1: Integer; A2: Integer);
begin end;

procedure TGlobalEnchantment.CenterToLocation(A1: Integer; A2: Integer);
begin end;

procedure TGlobalEnchantment.GetName(A1: Integer);
begin end;

procedure TGlobalEnchantment.GetUpkeep;
begin end;

procedure TGlobalEnchantment.VisibleForPlayer(A1: Integer; A2: Integer);
begin end;

procedure TGlobalEnchantment.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TGlobalEnchantment.Setup(A1: Integer; A2: Integer);
begin end;

procedure TGlobalEnchantment.CanActivate(A1: Integer; A2: Integer);
begin end;

procedure TGlobalEnchantment.Activate(A1: Byte; A2: Integer);
begin end;

procedure TGlobalEnchantment.CanDeactivate(A1: Integer; A2: Integer);
begin end;

procedure TGlobalEnchantment.Deactivate(A1: Byte);
begin end;

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

procedure TGlobalEnchantmentEventLog.GetLeftIcon;
begin end;

procedure TGlobalEnchantmentList.GetEnchantments(A1: Integer);
begin end;

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

procedure TGlobalMagicControl.GetSphereManaDoubled(A1: Integer);
begin end;

procedure TGlobalMagicControl.OutOfMana(A1: Byte; A2: Integer);
begin end;

procedure TGlobalMagicControl.RemovePlayerEnchantments(A1: Integer);
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

procedure TGlobalMagicControl.IndexOfID(A1: Integer);
begin end;

procedure TGlobalMagicControl.ValidateEnchantmentID(A1: Integer);
begin end;

procedure TGlobalMagicControl.CreateChangeMagicTE;
begin end;

procedure TGlobalMagicControl.ExecuteDispelEnchantment(A1: Integer; A2: Integer);
begin end;

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

