{ P4 abilities and magic.
  TAdjustableAbility and TDurationAbilityData are recovered; TDurationAbility
  is recovered except for NewDay's undeclared shared map global.
  Other classes below still contain their original draft bodies.
  Declaration adapters are temporary and marked with the owning package's needs. }

type
  P4LongString = ^string;
  { Temporary declaration views: no instances are created. }
  TDurationReturnView = class(TAbility)
    function GetDuration(AbilityOwner: TAbilityOwner): Byte; virtual; abstract;
    function GetTotalDuration: Integer; virtual; abstract;
  end;
  { needs: P3 TCombatObject.GetAbilityOwner: TAbilityOwner at VMT $B8.
    This declaration-only view preserves TEObject's slots through $48 and
    the TCombatObject slots $4C..$B8; no instances are created. }
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

resourcestring
  DurationDaysRStr = '(%s/%s days)';
  DurationCombatTurnRStr = '(%s/%s turns)';
  DurationEntireCombatRStr = '(combat only)';

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
  { needs: P1 global AoWHSMap: TAoWHSMap (558FA040); 55764D14 removes
    this ability from A1 when AoWHSMap.FDay = 1. }
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
    Data := AbilityOwner.DurationData(F_Ability_0C);
    if Data <> nil then
    begin
      if (Data.FDuration <> 0) and (PlayerIndex = Data.FPlayerIndex) then
      begin
        Dec(Data.FDuration);
        if Data.FDuration = 0 then
          AbilityOwner.RemoveAbility(F_Ability_0C);
      end;
    end
    else
      AbilityOwner.RemoveAbility(F_Ability_0C);
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
    Data := TAbilityOwnerP4(CombatObject.GetAbilityOwner).DurationData(F_Ability_0C);
    if Data <> nil then
    begin
      if (Data.FDuration <> 0) and (PlayerIndex = Data.FPlayerIndex) then
      begin
        Dec(Data.FDuration);
        if Data.FDuration = 0 then
          CombatObject.GetAbilityOwner.RemoveAbility(F_Ability_0C);
      end;
    end
    else
      CombatObject.GetAbilityOwner.RemoveAbility(F_Ability_0C);
  end;
end;

procedure TDurationAbility.CombatDone(A1: Integer);
begin
  case FDurationMode of
    dmCombatTurn, dmEntireCombat:
      TCombatOwnerReturnView(A1).GetAbilityOwner.RemoveAbility(F_Ability_0C);
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
  Data := TAbilityOwnerP4(AbilityOwner).DurationData(F_Ability_0C);
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
  MOV EDX, [EBP].TAbility.F_Ability_0C
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
  MOV AX, WORD PTR [EBP].TAbility.F_Ability_0C
  MOV [ESI].TDurationAbilityData.FAbilityID, AX
  MOV EAX, EBP
  MOV EDX, [EAX]
  CALL DWORD PTR [EDX + $110]
  MOV [ESI].TDurationAbilityData.FDuration, AL
  PUSH 1
  MOV ECX, [EBP].TAbility.F_Ability_0C
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
  MOV EDX, [EBP].TAbility.F_Ability_0C
  MOV EAX, ESI
  CALL TAbilityOwner.GetAbilityData
  MOV EDI, EAX
  TEST EDI, EDI
  JE @@Missing
  PUSH 0
  MOV ECX, [EBP].TAbility.F_Ability_0C
  MOV EDX, ESI
  MOV EAX, EBP
  CALL TAbility.SetAb
  MOV EDX, EDI
  MOV EAX, ESI
  CALL TAbilityOwner.RemoveAbilityData
  JMP @@Done
@@Missing:
  PUSH 0
  MOV ECX, [EBP].TAbility.F_Ability_0C
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
begin end;

class function TMultiLevelAbilityData.ClassID: Integer;
begin Result := 0; end;

procedure TMultiLevelAbilityData.GetAbilityID;
begin end;

constructor TMultiLevelAbility.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TMultiLevelAbility.Destroy;
begin end;

procedure TMultiLevelAbility.GetLevel(A1: Integer);
begin end;

procedure TMultiLevelAbility.GetInherentLevel(A1: Integer);
begin end;

procedure TMultiLevelAbility.AbilityDataClass;
begin end;

procedure TMultiLevelAbility.GetLevelName(A1: Integer; A2: Integer);
begin end;

procedure TMultiLevelAbility.GetName(A1: Integer; A2: Integer);
begin end;

procedure TMultiLevelAbility.ExpandName(A1: Integer; A2: Integer);
begin end;

procedure TMultiLevelAbility.ExpandCost;
begin end;

procedure TMultiLevelAbility.CanExpand(A1: Integer);
begin end;

procedure TMultiLevelAbility.GetSkillPoints(A1: Integer);
begin end;

procedure TMultiLevelAbility.Expand(A1: Integer; A2: Integer);
begin end;

procedure TMultiLevelAbility.Remove(A1: Integer; A2: Integer);
begin end;

constructor TUnitEnchantmentAbilityData.Create(AOwner: Engine.TECustomNode);
begin end;

class function TUnitEnchantmentAbilityData.ClassID: Integer;
begin Result := 0; end;

destructor TUnitEnchantmentAbilityData.Destroy;
begin end;

procedure TUnitEnchantmentAbilityData.GetAbilityID;
begin end;

procedure TUnitEnchantmentAbilityData.SetEnchantment(A1: Integer);
begin end;

procedure TUnitEnchantmentAbilityData.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

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
begin end;

destructor TSpell.Destroy;
begin end;

procedure TSpell.GetEnabled;
begin end;

procedure TSpell.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TSpell.CanActivate(A1: Integer; A2: Integer);
begin end;

procedure TSpell.Activate(A1: Integer; A2: Integer);
begin end;

procedure TSpell.CanActivateCombat(A1: Integer; A2: Integer);
begin end;

procedure TSpell.ActivateCombat(A1: Integer);
begin end;

procedure TSpell.CreateCA(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TSpell.GetCombatInfo(A1: Integer; A2: Integer);
begin end;

procedure TSpell.GetCombatDamageValue(A1: Integer; A2: Integer);
begin end;

procedure TSpell.GetCombatDamageValueEx(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TSpell.CastingDone(A1: Integer; A2: Integer);
begin end;

procedure TSpell.CombatCastingDone(A1: Integer; A2: Integer);
begin end;

procedure TSpell.CombatSpellCast(A1: Integer);
begin end;

procedure TSpell.PlayDefaultCastEffects(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TSpell.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TSpell.fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TSpell.fcPrefetchCombatCommands(A1: Integer);
begin end;

procedure TSpell.fcExecuteCombatCommand(A1: Integer; A2: Integer);
begin end;

procedure TSpell.tcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TSpell.tcGetDamageValue;
begin end;

procedure TSpell.CreateCastSpellAction;
begin end;

procedure TSpell.SetupCastSpellAction(A1: Integer; A2: Integer);
begin end;

procedure TSpell.AIRequestCastSpellExpense(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TSpell.AICastSpellExpenseMade(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TSpell.AIPrefetchCastSpellActions(A1: Integer; A2: Integer);
begin end;

procedure TSpell.AIExecuteCastSpellAction(A1: Integer);
begin end;

class function TSpellTE.ClassID: Integer;
begin Result := 0; end;

procedure TSpellTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TSpellTE.Initialize(A1: Integer; A2: Byte; A3: Integer; A4: Integer);
begin end;

procedure TSpellTE.GetSource;
begin end;

procedure TSpellTE.Validate(A1: Integer);
begin end;

procedure TSpellTE.Process(A1: Integer; A2: Integer);
begin end;

function TSpellTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TSpellTE.PlayDefaultCastEffects(A1: Integer; A2: Integer);
begin end;

constructor TSpellControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TSpellControl.Destroy;
begin end;

procedure TSpellControl.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TSpellControl.GetCount;
begin end;

procedure TSpellControl.GetSpell(A1: Integer);
begin end;

procedure TSpellControl.RegisterSpell(A1: Integer);
begin end;

procedure TSpellControl.UnregisterSpell(A1: Integer);
begin end;

procedure TSpellControl.UnregisterSpellID(A1: Integer);
begin end;

procedure TSpellControl.UnregisterAll;
begin end;

procedure TSpellControl.ListSpells(A1: Integer; A2: Word);
begin end;

procedure TSpellControl.GetRandomSpell(A1: Integer; A2: Integer; A3: Integer);
begin end;

constructor TSpellList.Create;
begin end;

destructor TSpellList.Destroy;
begin end;

procedure TSpellList.GetSpell(A1: Integer);
begin end;

procedure TSpellList.GetCount;
begin end;

procedure TSpellList.Add;
begin end;

procedure TSpellList.Delete;
begin end;

procedure TSpellList.Clear;
begin end;

procedure TSpellList.SortOnName;
begin end;

procedure TSpellList.SortOnLevel;
begin end;

constructor TSpellCaster.Create(AOwner: Engine.TECustomNode);
begin end;

function TSpellCaster.AddRef: Integer;
begin Result := 0; end;

function TSpellCaster.Release: Integer;
begin Result := 0; end;

procedure TSpellCaster.GetSource;
begin end;

procedure TSpellCaster.CanCast(A1: Integer);
begin end;

procedure TSpellCaster.Cast;
begin end;

constructor TCombatSpellCaster.Create(AOwner: Engine.TECustomNode);
begin end;

function TCombatSpellCaster.AddRef: Integer;
begin Result := 0; end;

function TCombatSpellCaster.Release: Integer;
begin Result := 0; end;

class function TSpellCastEventLog.ClassID: Integer;
begin Result := 0; end;

procedure TSpellCastEventLog.Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TSpellCastEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TSpellCastEventLog.ViewLocation(A1: Integer; A2: Integer);
begin end;

procedure TSpellCastEventLog.GetText(A1: Integer);
begin end;

constructor TUnitSpellCaster.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TUnitSpellCaster.Destroy;
begin end;

procedure TUnitSpellCaster.SetSelection(A1: Byte; A2: Integer);
begin end;

procedure TUnitSpellCaster.GetSelectionCount;
begin end;

procedure TUnitSpellCaster.GetRequiredMana;
begin end;

procedure TUnitSpellCaster.GetRequiredDays;
begin end;

procedure TUnitSpellCaster.CanCast(A1: Integer);
begin end;

procedure TUnitSpellCaster.Cast;
begin end;

procedure TUnitSpellCaster.Valid;
begin end;

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

procedure TEnchantment.SetSource(A1: Integer);
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
begin end;

procedure TPowerSource.Power;
begin end;

procedure TPowerSource.GetLocation(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TPowerSource.CenterToLocation(A1: Integer; A2: Integer);
begin end;

procedure TPowerSource.Select(A1: Integer; A2: Integer);
begin end;

procedure TPowerSourceList.GetItems(A1: Integer);
begin end;

procedure TExternalPowerSource.Name(A1: Integer);
begin end;

procedure TExternalPowerSource.Power;
begin end;

constructor TPlayerMagicEventLog.Create(AOwner: Engine.TECustomNode);
begin end;

class function TPlayerMagicEventLog.ClassID: Integer;
begin Result := 0; end;

procedure TPlayerMagicEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TPlayerMagicEventLog.ViewLocation(A1: Integer; A2: Integer);
begin end;

procedure TPlayerMagicEventLog.Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TPlayerMagicEventLog.GetText(A1: Integer);
begin end;

constructor TPlayerMagicControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TPlayerMagicControl.Destroy;
begin end;

procedure TPlayerMagicControl.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TPlayerMagicControl.GetCheatEnabled;
begin end;

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

procedure TPlayerMagicControl.RegisterEnchantment(A1: Integer);
begin end;

procedure TPlayerMagicControl.UnregisterEnchantment(A1: Integer);
begin end;

procedure TPlayerMagicControl.RegisterPowerSource(A1: Integer);
begin end;

procedure TPlayerMagicControl.UnregisterPowerSource(A1: Integer);
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

