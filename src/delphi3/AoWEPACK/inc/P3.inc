{ P3 combat implementation. Recovered methods precede the remaining drafts.
  TCombatUnit.Setup retains an ABI view for the one-argument SetCombatPlayer;
  its P5 override must be fixed before the shared declaration can be corrected.
  The two damage-effects entry-point casts preserve the original result while
  P2 still declares those functions as procedures. }
type
  TP3DamageFrames = function(Effects: TDamageTypes): Integer;
  TP3DamageType = function(Effects: TDamageTypes): TDamageType;
  TP3DamageIcon = procedure(X, Y, Surface, DamageType, Damage: Integer);
  TP3DamageRole = function(Damage, Attack: Integer): Integer;
  { ABI views for shared, unmarked procedure drafts in P4/P5. }
  TP3CombatDeactivateAccess = class(TEObject)
  public
    procedure Slot04C; virtual; abstract;
    procedure Slot050; virtual; abstract;
    procedure Slot054; virtual; abstract;
    procedure Slot058; virtual; abstract;
    procedure Slot05C; virtual; abstract;
    procedure Slot060; virtual; abstract;
    procedure Slot064; virtual; abstract;
    procedure Slot068; virtual; abstract;
    procedure Slot06C; virtual; abstract;
    procedure Slot070; virtual; abstract;
    procedure Deactivate; virtual; abstract;
  end;
  TP3ActionPlayAccess = class(TEObject)
  public
    procedure Slot04C; virtual; abstract;
    procedure Execute(Combat: TCombat); virtual; abstract;
    function Play(Viewer: TCombatViewer): Boolean; virtual; abstract;
  end;
  { needs: P2 GetStrength returns Integer and TUnitList.GetUnit returns TAbstractUnit. }
  TP3UnitStrength = function(U: TAbstractUnit; DamageType: TDamageType): Integer;
  TP3GetUnit = function(L: TUnitList; Index: Integer): TAbstractUnit;
  { needs: P2 TAbstractUnit.GetCombatValue returns Integer ($5572A6FE). }
  TP3CombatValue = function(U: TAbstractUnit; Target: Integer; Mode: Byte): Integer;
  { needs: P5 unmarked +$60 byte is TFastCombatUnitState ($5572A4C0). }
  TP3FastStateView = class(TObject)
  public
    Reserved: array[4..$5F] of Byte;
    State: TFastCombatUnitState;
  end;
  TP3NodeAccess = class(TENode)
  public
    property ChildrenList: TEObjectList read FChildren;
  end;
  PP3String = ^string;
  { needs: P2 nonvirtual damage-effects routines return TDamageTypes. The typed
    entry-point casts preserve the register ABI until the declarations are fixed. }
  TP3ExecuteCombatDamageEffects = function(U: TAbstractUnit; Combat: Integer;
    Effects: TDamageTypes): TDamageTypes;
  TP3ExecuteDamageEffectsRole = function(U: TAbstractUnit; Effects: TDamageTypes): TDamageTypes;
  { ABI view only; never instantiated. needs: P2 TAbstractUnit's two
    procedure drafts at +$144/+$148 are Integer/Boolean getters. }
  TP3AbstractUnitAccess = class(TAbilityOwner)
  public
    procedure Slot09C; virtual; abstract; { +$09C }
    function UnitLevel: Byte; virtual; abstract; { +$0A0 }
    procedure Slot0A4; virtual; abstract; { +$0A4 }
    procedure Slot0A8; virtual; abstract; { +$0A8 }
    procedure Slot0AC; virtual; abstract; { +$0AC }
    procedure Slot0B0; virtual; abstract; { +$0B0 }
    procedure Slot0B4; virtual; abstract; { +$0B4 }
    procedure Slot0B8; virtual; abstract; { +$0B8 }
    procedure Slot0BC; virtual; abstract; { +$0BC }
    function Attack: Shortint; virtual; abstract; { +$0C0 }
    function Defense: Shortint; virtual; abstract; { +$0C4 }
    function Damage: Shortint; virtual; abstract; { +$0C8 }
    function Resistance: Shortint; virtual; abstract; { +$0CC }
    function Hits: Byte; virtual; abstract; { +$0D0 }
    function Moves: Shortint; virtual; abstract; { +$0D4 }
    procedure Slot0D8; virtual; abstract; { +$0D8 }
    procedure Slot0DC; virtual; abstract; { +$0DC }
    function HitPoints: Shortint; virtual; abstract; { +$0E0 }
    procedure SetHitPoints(Value: Byte); virtual; abstract; { +$0E4 }
    procedure Slot0E8; virtual; abstract; { +$0E8 }
    function Immunities: TDamageTypes; virtual; abstract; { +$0EC }
    function Protections: TDamageTypes; virtual; abstract; { +$0F0 }
    procedure Slot0F4; virtual; abstract; { +$0F4 }
    procedure Slot0F8; virtual; abstract; { +$0F8 }
    function Alignment: TAlignment; virtual; abstract; { +$0FC }
    procedure Slot100; virtual; abstract; { +$100 }
    procedure Slot104; virtual; abstract; { +$104 }
    procedure Slot108; virtual; abstract; { +$108 }
    procedure Slot10C; virtual; abstract; { +$10C }
    procedure Slot110; virtual; abstract; { +$110 }
    procedure Slot114; virtual; abstract; { +$114 }
    procedure Slot118; virtual; abstract; { +$118 }
    procedure Slot11C; virtual; abstract; { +$11C }
    function WallFeatures: TWallCombatFeatures; virtual; abstract; { +$120 }
    procedure Slot124; virtual; abstract; { +$124 }
    procedure Slot128; virtual; abstract; { +$128 }
    procedure Slot12C; virtual; abstract; { +$12C }
    procedure Slot130; virtual; abstract; { +$130 }
    procedure Slot134; virtual; abstract; { +$134 }
    procedure Slot138; virtual; abstract; { +$138 }
    procedure Slot13C; virtual; abstract; { +$13C }
    procedure Slot140; virtual; abstract; { +$140 }
    function GetAbilityLevel(Ability: Integer): Integer; virtual; abstract;
    function GetAbilityEnabled(Ability: Integer): Boolean; virtual; abstract;
    procedure Slot14C; virtual; abstract;
    procedure Slot150; virtual; abstract;
    procedure Slot154; virtual; abstract;
    function AbilityCount: Integer; virtual; abstract;
    function Experience: Integer; virtual; abstract;
    procedure SetExperience(Value: Integer); virtual; abstract;
    procedure Slot164; virtual; abstract;
    procedure Slot168; virtual; abstract;
    procedure Slot16C; virtual; abstract;
    procedure Slot170; virtual; abstract;
    function ObtainValue: Integer; virtual; abstract;

  end;
  { needs: P3 TCombatObject.SetCombatPlayer takes one Byte; changing its
    declaration also requires P5 TFastCombatUnit's override to be corrected. }
  TP3CombatPlayerAccess = class(TEObject)
  public
    procedure Slot04C; virtual; abstract;
    procedure Slot050; virtual; abstract;
    procedure Slot054; virtual; abstract;
    procedure Slot058; virtual; abstract;
    procedure Slot05C; virtual; abstract;
    procedure Slot060; virtual; abstract;
    procedure Slot064; virtual; abstract;
    procedure SetCombatPlayer(Player: Byte); virtual; abstract;
  end;

const
  P3InfoSample: packed record
    RefCount, Length: Integer;
    Text: array[0..20] of Char;
  end = (RefCount: -1; Length: 20; Text: 'SFX\EVENTS\INFO2.WAV'#0);
var
  P3HitProbabilities: array[0..19] of Single;

constructor TCombatUnit.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FControlMode := [cmConquerObject];
  FUnitGFXResourceIndex := -1;
end;

destructor TCombatUnit.Destroy;
begin
  SetUnit(0);
  inherited Destroy;
end;

class function TCombatUnit.ClassID: Integer;
begin Result := $202A1; end;

procedure TCombatUnit.Setup(A1: Byte; A2: Integer; A3: Integer; A4: Byte; A5: Byte);
begin
  FID := A1;
  FPosition := A4;
  with TP3CombatPlayerAccess(Self) do SetCombatPlayer(A5);
  SetUnit(A3);
end;

function TCombatUnit.GetVisibilityRange: Integer;
var
  Level: Integer;
  U: TAbstractUnit;
begin
  U := FUnit;
  if U <> nil then
  begin
    { needs: P2 TAbstractUnit.GetAbilityLevel returns Integer (+$144),
      GetAbilityEnabled returns Boolean (+$148); original calls at $55724AE2/$55724B0D. }
    Level := TP3AbstractUnitAccess(U).GetAbilityLevel($40);
    if Level <> 0 then
      Result := Level * 2 + 4
    else
      Result := 4;
    if (TCombat(FCombat).F_Combat_40 = 1) and
       not TP3AbstractUnitAccess(FUnit).GetAbilityEnabled($27) then
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
  { needs: P2 Boolean result for TAbstractUnit.GetAbilityEnabled. }
  Result := TP3AbstractUnitAccess(FUnit).GetAbilityEnabled($5F) or
    TP3AbstractUnitAccess(FUnit).GetAbilityEnabled($61) or
    TP3AbstractUnitAccess(FUnit).GetAbilityEnabled($5C) or
    TP3AbstractUnitAccess(FUnit).GetAbilityEnabled($5E) or
    TP3AbstractUnitAccess(FUnit).GetAbilityEnabled($22);
end;

function TCombatUnit.WallCombatFeatures: TWallCombatFeatures;
begin Result := FWallCombatFeatures; end;

function TCombatUnit.ExecuteDamageEffects(A1: TDamageTypes): TDamageTypes;
begin
  { needs: P2 TAbstractUnit.ExecuteCombatDamageEffects(Combat, Effects): TDamageTypes;
    $55724C2F calls it with Self in EAX, combat in EDX, effects in CX. }
  Result := TP3ExecuteCombatDamageEffects(@TAbstractUnit.ExecuteCombatDamageEffects)(
    FUnit, Integer(FCombat), A1);
end;

function TCombatUnit.ExecuteDamageEffectsRole(A1: TDamageTypes): TDamageTypes;
begin
  { needs: P2 TAbstractUnit.ExecuteDamageEffectsRole(Effects): TDamageTypes;
    $55724C4C consumes the damage-effect set result from AX. }
  Result := TP3ExecuteDamageEffectsRole(@TAbstractUnit.ExecuteDamageEffectsRole)(FUnit, A1);
end;

procedure TCombatUnit.UpdateWallCombatFeatures;
begin end;

procedure TCombatUnit.Activate(A1: Integer);
begin end;

procedure TCombatUnit.Deactivate;
begin end;

procedure TCombatUnit.Initialize(A1: Integer);
begin end;

procedure TCombatUnit.Finalize(A1: Integer);
begin end;

procedure TCombatUnit.PlaySFX(A1: Byte);
begin end;

function TCombatUnit.GetMoves: Integer;
begin Result := TP3AbstractUnitAccess(FUnit).Moves; end;

function TCombatUnit.GetAlignment: TAlignment;
begin Result := TP3AbstractUnitAccess(FUnit).Alignment; end;

function TCombatUnit.GetAbilityOwner: TAbilityOwner;
begin Result := FUnit; end;

function TCombatUnit.GetAbilityEnabled(A1: Integer): Boolean;
begin
  if FUnit <> nil then Result := TP3AbstractUnitAccess(FUnit).GetAbilityEnabled(A1) else Result := False;
end;

procedure TCombatUnit.SetAbilityEnabled(A1: Integer; A2: Boolean);
begin FUnit.SetAbSet(A1, Byte(A2)); end;

function TCombatUnit.GetAbilityLevel(A1: Integer): Integer;
begin Result := TP3AbstractUnitAccess(FUnit).GetAbilityLevel(A1); end;

function TCombatUnit.GetAbilityCount: Integer;
begin
  if FUnit <> nil then Result := TP3AbstractUnitAccess(FUnit).AbilityCount else Result := 0;
end;

function TCombatUnit.GetHits: Byte;
var U: TP3AbstractUnitAccess;
begin
  U := TP3AbstractUnitAccess(FUnit);
  if U <> nil then Result := U.Hits else Result := 0;
end;

function TCombatUnit.GetHitPoints: Shortint;
var U: TP3AbstractUnitAccess;
begin
  U := TP3AbstractUnitAccess(FUnit);
  if U <> nil then Result := U.HitPoints else Result := 0;
end;

procedure TCombatUnit.SetHitPoints(A1: Byte);
var U: TP3AbstractUnitAccess;
begin
  U := TP3AbstractUnitAccess(FUnit);
  if U <> nil then U.SetHitPoints(A1);
end;

procedure TCombatUnit.SetParty(A1: Integer);
begin end;

procedure TCombatUnit.UpdateParty;
begin end;

procedure TCombatUnit.UpdateUnitGFXResource;
begin end;

procedure TCombatUnit.ReleaseUnitGFXResource;
begin end;

procedure TCombatUnit.SetUnit(A1: Integer);
begin end;

procedure TCombatUnit.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TCombatUnit.ObjectDestroyed(A1: Integer);
begin end;

procedure TCombatUnit.GetTargetCVDV(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TCombatUnit.GetTargetWallCV(A1: Integer);
begin end;

function TCombatUnit.GetAttack: Shortint;
begin Result := TP3AbstractUnitAccess(FUnit).Attack; end;

function TCombatUnit.GetDefense: Shortint;
begin Result := TP3AbstractUnitAccess(FUnit).Defense; end;

function TCombatUnit.GetResistance: Shortint;
begin Result := TP3AbstractUnitAccess(FUnit).Resistance; end;

function TCombatUnit.GetDamage: Shortint;
begin Result := TP3AbstractUnitAccess(FUnit).Damage; end;

function TCombatUnit.GetImmunityTypes: TDamageTypes;
begin Result := TP3AbstractUnitAccess(FUnit).Immunities + TCombatData(TCombat(FCombat).FCombatData).F_CombatData_22; end;

function TCombatUnit.GetProtectionTypes: TDamageTypes;
begin Result := TP3AbstractUnitAccess(FUnit).Protections; end;

function TCombatUnit.GetExperience: Integer;
begin Result := TP3AbstractUnitAccess(FUnit).Experience; end;

procedure TCombatUnit.SetExperience(A1: Integer);
begin with TP3AbstractUnitAccess(FUnit) do SetExperience(A1); end;

function TCombatUnit.GetLevel: Byte;
begin Result := TP3AbstractUnitAccess(FUnit).UnitLevel; end;

function TCombatUnit.IDStr: string;
begin Result := ''; end;

procedure TCombatUnit.SupportCombatMode(A1: Byte; A2: Integer);
begin end;

procedure TCombatUnit.SetStatus(A1: Byte; A2: Integer);
begin end;

procedure TCombatUnit.KillUnit;
begin end;

procedure TCombatUnit.DestroyObject;
begin end;

procedure TCombatUnit.Surrender;
begin end;

function TCombatUnit.GetTargetPriority: Integer;
begin Result := 0; end;

function TCombatUnit.GetTargetStrength: Integer;
begin Result := 0; end;

procedure TCombatUnit.CommandingTargetPriority(A1: Integer; A2: Integer);
begin end;

procedure TCombatUnit.CommandingTargetStrength(A1: Integer; A2: Integer);
begin end;

procedure TCombatUnit.Show(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TCombatUnit.ShowAttackAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TCombatUnit.ShowHitAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

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
begin Result := 0; end;

function TCombatWall.GetTargetStrength: Integer;
begin
  if not FLocked then
    if not TCombatData(TCombat(FCombat).FCombatData).F_CombatData_4D then Result := 10
    else Result := 1
  else Result := 0;
end;

procedure TCombatWall.fcRoundDistance;
{ needs: Integer result; P5 has an unmarked procedure override. }
asm XOR EAX, EAX end;

procedure TCombatWall.Setup(A1: Byte; A2: Byte; A3: Integer);
begin
  FID := A1;
  FWallType := A2;
  FHitPoints := GetHits;
  TP3CombatPlayerAccess(Self).SetCombatPlayer(Byte(A3));
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
  TCombatData(TCombat(FCombat).FCombatData).F_CombatData_4D := True;
end;

procedure TCombatWall.Show(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TCombatWall.ShowAttackAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
{ needs: Boolean result; P5's animation override is unmarked. }
asm
  PUSH EBX
  PUSH ESI
  MOV ESI, EAX
  MOV EAX, [EBP+$10]
  PUSH EAX
  MOV EAX, [EBP+$0C]
  PUSH EAX
  MOV EAX, [EBP+8]
  PUSH EAX
  MOV EAX, ESI
  MOV EBX, [EAX]
  CALL DWORD PTR [EBX+$0FC]
  XOR EAX, EAX
  POP ESI
  POP EBX
end;

procedure TCombatWall.ShowHitAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
{ needs: Boolean result; P5's animation override is unmarked. }
asm
  PUSH EBX
  PUSH ESI
  MOV ESI, EAX
  MOV EAX, [EBP+$10]
  PUSH EAX
  MOV EAX, [EBP+$0C]
  PUSH EAX
  MOV EAX, [EBP+8]
  PUSH EAX
  MOV EAX, ESI
  MOV EBX, [EAX]
  CALL DWORD PTR [EBX+$0FC]
  XOR EAX, EAX
  POP ESI
  POP EBX
end;

constructor TCombatObject.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TCombatObject.Destroy;
begin end;

procedure TCombatObject.TargetsChanged;
begin F_CombatObject_3C := 1; F_CombatObject_44 := 1; end;

procedure TCombatObject.AddTarget(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TCombatObject.DeleteTarget(A1: Integer);
begin end;

procedure TCombatObject.RemoveTarget(A1: Integer);
begin end;

procedure TCombatObject.ResetTargets;
begin end;

procedure TCombatObject.GetTargetCVDV(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TCombatObject.GetTargetWallCV(A1: Integer);
begin end;

function TCombatObject.GetTargetPriority: Integer;
begin Result := 0; end;

function TCombatObject.GetTargetStrength: Integer;
var I: Integer;
begin
  if F_CombatObject_44 <> 0 then
  begin
    F_CombatObject_40 := 0;
    for I := TQuadItemList(F_CombatObject_10).Count - 1 downto 0 do
      Inc(F_CombatObject_40, TQuadItemList(F_CombatObject_10).List^[I].D);
    if F_CombatObject_40 <> 0 then F_CombatObject_40 := F_CombatObject_40 div TQuadItemList(F_CombatObject_10).Count;
    F_CombatObject_44 := 0;
    Result := F_CombatObject_40;
    Exit;
  end;
  Result := F_CombatObject_40;
end;

procedure TCombatObject.SetupTargets;
begin end;

procedure TCombatObject.ObjectSideChanged(A1: Integer);
begin end;

procedure TCombatObject.fcExecute(A1: Integer);
{ needs: result declaration also requires unmarked P5 overrides to change. }
asm XOR EAX, EAX end;

function TCombatObject.fcBehindWall: Boolean;
{ needs: result declaration also requires unmarked P5 overrides to change. }
asm XOR EAX, EAX end;

function TCombatObject.fcWallInBetween(A1: Byte): Boolean;
{ needs: result declaration also requires unmarked P5 overrides to change. }
asm XOR EAX, EAX end;

procedure TCombatObject.fcRoundDistance;
{ needs: result declaration also requires unmarked P5 overrides to change. }
asm XOR EAX, EAX end;

function TCombatObject.GetVisibilityRange: Integer;
begin Result := 0; end;

procedure TCombatObject.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TCombatObject.WallCombatFeatures: TWallCombatFeatures;
begin Result := []; end;

function TCombatObject.GetEnabled: Boolean;
begin Result := [csDestroyed, csFled] * FStatus = []; end;

function TCombatObject.GetSide: TCombatSideIndex;
var Player: Shortint;
begin
  Player := Shortint(F_CombatObject_45);
  if Player <> -1 then
    Result := TCombatSideIndex(TCombatPlayerList(TCombatData(TCombat(FCombat).FCombatData).F_CombatData_38).GetPlayers(Player).F_CombatPlayer_0A)
  else Result := csNeutral;
end;

function TCombatObject.GetOpponentSide: TCombatSideIndex;
var Player: Shortint;
begin
  Player := Shortint(F_CombatObject_45);
  if Player <> -1 then
    Result := TCombatSideIndex(TCombatPlayerList(TCombatData(TCombat(FCombat).FCombatData).F_CombatData_38).GetPlayers(Player).F_CombatPlayer_0A xor 1)
  else Result := csNeutral;
end;

procedure TCombatObject.NewTurn(A1: Byte);
begin if A1 = F_CombatObject_45 then FStatus := FStatus - [csTurnDone]; end;

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
begin end;

procedure TCombatObject.Deactivate;
begin end;

procedure TCombatObject.Initialize(A1: Integer);
begin end;

procedure TCombatObject.Finalize(A1: Integer);
begin end;

procedure TCombatObject.PlaySFX(A1: Byte);
begin end;

function TCombatObject.GetLocked: Boolean;
begin Result := False; end;

procedure TCombatObject.SetCombatPlayer(A1: Integer; A2: Integer);
begin end;

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

procedure TCombatObject.GetPlayer;
begin end;

procedure TCombatObject.GetPlayerIR;
begin end;

procedure TCombatObject.ObjectDestroyed(A1: Integer);
begin end;

procedure TCombatObject.SupportCombatMode(A1: Byte; A2: Integer);
begin end;

procedure TCombatObject.GetOptimalDamageType(A1: Word; A2: Integer);
begin end;

function TCombatObject.ExecuteDamageRole(A1: Integer; A2: Integer; A3: TDamageTypes): Integer;
var Immunity: TDamageTypes;
begin
  Result := 0;
  Immunity := GetImmunityTypes;
  if (A3 - Immunity) <> [] then
  begin
    { needs: P1 unit ExecuteDamageRole returns Integer, not procedure. }
    Result := TP3DamageRole(@AoWE.ExecuteDamageRole)(A2, A1 - GetDefense);
    if (A3 - Immunity - GetProtectionTypes) = [] then Result := (Result + 1) div 2;
  end;
end;

function TCombatObject.ExecuteDamageRoleEx(A1: Integer; A2: Integer; A3: TDamageTypes; A4: Byte): Integer;
var Immunity: TDamageTypes; Defense: Shortint;
begin
  Result := 0;
  Immunity := GetImmunityTypes;
  if (A3 - Immunity) <> [] then
  begin
    if A4 = 1 then Defense := GetResistance else Defense := GetDefense;
    { needs: P1 unit ExecuteDamageRole returns Integer, not procedure. }
    Result := TP3DamageRole(@AoWE.ExecuteDamageRole)(A2, A1 - Defense);
    if (A3 - Immunity - GetProtectionTypes) = [] then Result := (Result + 1) div 2;
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
begin end;

procedure TCombatObject.Surrender;
begin end;

function TCombatObject.ExecuteDamage(A1: Integer): Integer;
begin Result := 0; end;

procedure TCombatObject.Show(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TCombatObject.ShowAttackAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
{ needs: result declaration also requires unmarked P5 overrides to change. }
asm XOR EAX, EAX end;

procedure TCombatObject.ShowHitAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
{ needs: result declaration also requires unmarked P5 overrides to change. }
asm XOR EAX, EAX end;

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
begin end;

procedure TCombatSide.UpdateSettings;
var I, N: Integer; Obj: TCombatObject;
begin
  F_CombatSide_14 := 0;
  F_CombatSide_18 := 0;
  for I := FChildren.Count - 1 downto 0 do
  begin
    Obj := TCombatObject(FChildren.List^[I]);
    N := TQuadItemList(Obj.F_CombatObject_10).Count;
    if N > 0 then Inc(F_CombatSide_14, Obj.F_CombatObject_18 div N);
    if (TQuadItemList(Obj.F_CombatObject_14).Count > 0) and
      (Obj.F_CombatObject_30 = 0) then Inc(F_CombatSide_18);
  end;
end;

constructor TCombat.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  F_Combat_24 := Integer(TEventList.Create);
  F_Combat_1C := Integer(TCombatSide.Create(nil));
  F_Combat_20 := Integer(TCombatSide.Create(nil));
  TCombatSide(F_Combat_1C).F_CombatSide_0C := 0;
  TCombatSide(F_Combat_20).F_CombatSide_0C := 1;
  TCombatSide(F_Combat_1C).FOpponent := TCombatSide(F_Combat_20);
  TCombatSide(F_Combat_20).FOpponent := TCombatSide(F_Combat_1C);
  FCombatData := TCombatData.Create(nil);
  F_Combat_18 := Integer(TCombatLogbook.Create(nil));
  Clear;
end;

destructor TCombat.Destroy;
begin
  if cActivated in F_Combat_08 then TP3CombatDeactivateAccess(Self).Deactivate;
  if cExecuting in F_Combat_08 then Finalize;
  TObject(F_Combat_24).Free;
  TObject(F_Combat_1C).Free;
  TObject(F_Combat_20).Free;
  TObject(FCombatData).Free;
  TCombatLogbook(F_Combat_18).Release;
  inherited Destroy;
end;

function TCombat.GetLogCombatActions: Boolean;
begin Result := cLogCombatActions in F_Combat_08; end;

procedure TCombat.SetLogCombatActions(A1: Byte);
begin
  if A1 <> 0 then F_Combat_08 := F_Combat_08 + [cLogCombatActions]
  else F_Combat_08 := F_Combat_08 - [cLogCombatActions];
end;

procedure TCombat.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwEObject(TEObject(F_Combat_1C), $0A);
  Stream.rwEObject(TEObject(F_Combat_20), $0B);
  Stream.rwCreateEObject(TEObject(F_Combat_18), nil, $0C);
  Stream.rwEObject(TEObject(FCombatData), $0D);
end;

function TCombat.GetRound: Integer;
begin Result := TCombatData(FCombatData).F_CombatData_44; end;

procedure TCombat.ExecuteCombatAction(A1: TCombatAction);
begin
  if cLogCombatActions in F_Combat_08 then TCombatActionList(TCombatLogbook(F_Combat_18).F_CombatLogbook_14).AddChild(TCombatAction(A1));
  TP3ActionPlayAccess(A1).Execute(Self);
end;

procedure TCombat.PlayerTypeInvolved(A1: Byte; A2: Integer);
begin end;

function TCombat.CreateUniqueCOID: Byte;
begin Result := F_Combat_10; Inc(F_Combat_10); end;

procedure TCombat.Clear;
begin
  inherited Clear;
  TCombatLogbook(F_Combat_18).Clear;
  F_Combat_10 := 1;
  TCombatData(FCombatData).Clear;
  F_Combat_08 := [];
end;

procedure TCombat.Setup(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer; A8: Integer; A9: Integer; A10: Integer; A11: Integer);
begin end;

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
begin TCombatSide(F_Combat_1C).UpdateSettings; TCombatSide(F_Combat_20).UpdateSettings; end;

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
    I := TByteList(TCombatData(FCombatData).F_CombatData_40).IndexOf(TCombatData(FCombatData).F_CombatData_31) + 1;
    if I >= TByteList(TCombatData(FCombatData).F_CombatData_40).Count then I := 0;
    NewTurn(TByteList(TCombatData(FCombatData).F_CombatData_40)[I]);
  end;
end;

procedure TCombat.Terminate;
begin
  if not F_Combat_34 then
  begin
    F_Combat_34 := True;
    if Assigned(FOnTerminated) then FOnTerminated(Self);
  end;
end;

procedure TCombat.CheckTerminate;
begin
  if not F_Combat_34 then
    if (TCombatSide(F_Combat_1C).GetUndestroyedConquerObjects = 0) or
      (TCombatSide(F_Combat_20).GetUndestroyedConquerObjects = 0) or
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
  TEventList(F_Combat_24).TriggerNotifyEvents(Self);
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
begin end;

procedure TCombat.GetPartyPosition(A1: Integer; A2: Integer; A3: Integer);
begin end;

function TCombat.CreateCombatPlayer: Integer;
begin Result := Integer(TCombatPlayer.Create(nil)); end;

procedure TCombat.AddCombatPlayer(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TCombat.AddArmy(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TCombat.AddArmyEx(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer; A6: Integer);
begin end;

procedure TCombat.AddEmptyArmy(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TCombat.InitDefaultArmies(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TCombat.Initialize;
begin end;

procedure TCombat.Finalize;
begin end;

procedure TCombat.LockExecuted;
begin Inc(F_Combat_28); end;

procedure TCombat.UnlockExecuted;
begin
  Dec(F_Combat_28);
  if (F_Combat_28 = 0) and Assigned(FOnExecuted) then FOnExecuted(Self);
end;

procedure TCombat.Activate;
var I: Integer;
begin
  Assert(not (cActivated in F_Combat_08), 'Combat already activated');
  F_Combat_08 := F_Combat_08 + [cActivated];
  TCombatPartyList(TCombatData(FCombatData).F_CombatData_3C).Activate(Integer(Self));
  for I := TCombatData(FCombatData).GetCount - 1 downto 0 do
    TCombatData(FCombatData).GetObjects(I).Activate(Integer(Self));
  if cExecuting in F_Combat_08 then
  begin
    for I := TCombatData(FCombatData).GetCount - 1 downto 0 do
      TCombatData(FCombatData).GetObjects(I).SetupTargets;
    UpdateSidesSettings;
  end;
end;

procedure TCombat.Deactivate(A1: Integer; A2: Integer);
var I: Integer;
begin
  Assert(cActivated in F_Combat_08, 'Combat Failure during Deactivating');
  F_Combat_08 := F_Combat_08 - [cActivated];
  for I := TCombatData(FCombatData).GetCount - 1 downto 0 do
    TCombatData(FCombatData).GetObjects(I).Deactivate;
  TCombatPartyList(TCombatData(FCombatData).F_CombatData_3C).Deactivate(Integer(Self));
end;

function TCombat.Execute: Byte;
begin Result := 0; end;

procedure TCombat.UpdateStatus;
begin end;

procedure TCombat.GetCombatResultText(A1: Integer);
begin end;

function TCombat.DefendersAvailable: Boolean;
var I: Integer; Obj: TCombatObject;
begin
  Result := False;
  I := 0;
  while not Result and (I <> TCombatData(FCombatData).GetCount) do
  begin
    Obj := TCombatData(FCombatData).GetObjects(I);
    Result := (Obj.F_CombatObject_45 <> $FF) and
      (TCombatPlayerList(TCombatData(FCombatData).F_CombatData_38).GetPlayers(Shortint(Obj.F_CombatObject_45)).F_CombatPlayer_0A = 1) and
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

function TCombatTypeRequestEventLog.Execute(Mode: Integer; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
asm
  PUSH EBX
  PUSH DWORD PTR [EBP+$0C]
  PUSH DWORD PTR [EBP+8]
  CALL EventLog.TEventLog.Execute
  POP EBX
end;

procedure TCombatTypeRequestEventLog.Select(A1: Byte);
begin F_CombatTypeRequestEventLog_18 := A1; end;

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
{ needs: P2 TArmy.SetPlayer(Byte), proven by MOV DL at $55728664. }
asm
  PUSH EBX
  PUSH ESI
  MOV ESI, EDX
  MOV EBX, EAX
  MOV EAX, [ESI+$0C]
  MOV EAX, [EAX+$38]
  MOV DL, [EBX+$1A]
  CALL TCombatPlayerList.GetPlayers
  MOV DL, [EAX+8]
  MOV EAX, [EBX+8]
  CALL TArmy.SetPlayer
  POP ESI
  POP EBX
end;

procedure TCombatParty.Deactivate(A1: Integer);
begin end;

function TCombatPartyList.GetControlStyle: Engine.TEControlStyles;
begin Result := [csSaveLoad, csArrayMode]; end;

function TCombatPartyList.CreateParty(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer): TCombatParty;
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
      TCombatPlayerList(TCombatData(TCombat(A1).FCombatData).F_CombatData_38).
        GetPlayers(Shortint(A3)).F_CombatPlayer_08);
    if A7 <> 0 then TArmy(P.F_CombatParty_08).AssignSettings(A7);
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
  Stream.rwByte(F_CombatPlayer_08, $14);
  Stream.rwByte(F_CombatPlayer_09, $15);
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
    if TCombatPlayer(FChildren.List^[Result]).F_CombatPlayer_08 = A1 then Exit;
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
    if (P.F_CombatPlayer_08 = A1) and (P.F_CombatPlayer_09 = A2) then Exit;
  end;
  Result := -1;
end;

procedure TCombatPlayerList.Delete(A1: Integer);
begin GetPlayers(Shortint(A1)).Free; end;

constructor TCombatData.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  F_CombatData_38 := Integer(TCombatPlayerList.Create(nil));
  F_CombatData_3C := Integer(TCombatPartyList.Create(nil));
  F_CombatData_34 := Integer(TENode.Create(nil));
  F_CombatData_2C := Integer(TByteList.Create);
  F_CombatData_40 := Integer(TByteList.Create);
  F_CombatData_28 := Integer(TByteList.Create);
end;

destructor TCombatData.Destroy;
begin
  TObject(F_CombatData_3C).Free;
  TObject(F_CombatData_38).Free;
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
  Stream.rwByte(F_CombatData_24, $0E);
  Stream.rwByte(F_CombatData_25, $0F);
  Stream.rwData(F_CombatData_30, 1, $10);
  Stream.rwInteger(F_CombatData_44, $11);
  Stream.rwEObject(TEObject(F_CombatData_38), $12);
  Stream.rwEObject(TEObject(F_CombatData_34), $13);
  Stream.rwEObject(TEObject(F_CombatData_3C), $14);
  Stream.rwString(F_CombatData_48, $15);
  Stream.rwInteger(F_CombatData_14, $16);
  Stream.rwInteger(F_CombatData_18, $17);
  Stream.rwInteger(F_CombatData_1C, $18);
  Stream.rwStreamProc($19, TByteList(F_CombatData_2C).LoadFromStream, TByteList(F_CombatData_2C).SaveToStream);
  Stream.rwStreamProc($1A, TByteList(F_CombatData_40).LoadFromStream, TByteList(F_CombatData_40).SaveToStream);
  Stream.rwData(F_CombatData_4C, 1, $1B);
  Stream.rwBool(F_CombatData_4D, $1C);
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
    Result := TCombatPlayerList(F_CombatData_38).GetPlayers(Shortint(TByteList(F_CombatData_28)[I])).F_CombatPlayer_0A = A1;
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
  TCombatPlayerList(F_CombatData_38).Clear;
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
var Obj, Found: TCombatObject; I: Integer;
begin
  Found := nil;
  I := TP3NodeAccess(F_CombatData_34).ChildrenList.Count;
  while (I <> 0) and (Found = nil) do
  begin
    Dec(I);
    Obj := TCombatObject(TP3NodeAccess(F_CombatData_34).ChildrenList.List^[I]);
    if Obj.FPosition = A1 then Found := Obj;
  end;
  Result := Found;
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
  F_CombatLogbook_08 := 1;
  F_CombatLogbook_14 := Integer(TCombatActionList.Create(nil));
  F_CombatLogbook_10 := Integer(TCombatData.Create(nil));
  F_CombatLogbook_0C := Integer(TCombatData.Create(nil));
  F_CombatLogbook_19 := False;
end;

destructor TCombatLogbook.Destroy;
begin
  Clear;
  TObject(F_CombatLogbook_14).Free;
  TObject(F_CombatLogbook_10).Free;
  TObject(F_CombatLogbook_0C).Free;
  inherited Destroy;
end;

procedure TCombatLogbook.SetInitialData;
begin end;

procedure TCombatLogbook.SetFinalData;
begin end;

procedure TCombatLogbook.Clear;
begin
  TEObject(F_CombatLogbook_10).Clear;
  TEObject(F_CombatLogbook_0C).Clear;
  TEObject(F_CombatLogbook_14).Clear;
end;

class function TCombatLogbook.ClassID: Integer;
begin Result := $202A5; end;

function TCombatLogbook.AddRef: Integer;
begin Inc(F_CombatLogbook_08); Result := F_CombatLogbook_08; end;

function TCombatLogbook.Release: Integer;
var N: Integer;
begin
  Dec(F_CombatLogbook_08);
  N := F_CombatLogbook_08;
  Result := N;
  if N = 0 then Destroy;
end;

procedure TCombatLogbook.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwEObject(TEObject(F_CombatLogbook_0C), 5);
  Stream.rwEObject(TEObject(F_CombatLogbook_10), 6);
  Stream.rwEObject(TEObject(F_CombatLogbook_14), 7);
  Stream.rwBool(F_CombatLogbook_19, 8);
end;

destructor TCombatEventLog.Destroy;
var L: TCombatLogbook;
begin
  L := TCombatLogbook(F_CombatEventLog_18);
  if L <> nil then begin L.Release; F_CombatEventLog_18 := nil; end;
  inherited Destroy;
end;

class function TCombatEventLog.ClassID: Integer;
begin Result := $202E2; end;

procedure TCombatEventLog.SetCombatLogbook(Logbook: TCombatLogbook);
var Old: TCombatLogbook;
begin
  Old := F_CombatEventLog_18;
  if Logbook <> Old then
  begin
    if Old <> nil then Old.Release;
    F_CombatEventLog_18 := Logbook;
    if F_CombatEventLog_18 <> nil then F_CombatEventLog_18.AddRef;
  end;
end;

procedure TCombatEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin inherited ReadWrite(Stream); Stream.rwCreateEObject(TEObject(F_CombatEventLog_18), nil, $14); end;

function TCombatEventLog.GetTextColor: TColor;
begin Result := 0; end;

function TCombatEventLog.GetLeftIcon: Integer;
begin Result := 0; end;

function TCombatEventLog.GetMiddleIcon: Integer;
{ needs: Integer result in EventLog's unmarked interface. }
asm MOV EAX, $0D end;

function TCombatEventLog.GetRightIcon: Integer;
begin Result := 0; end;

function TCombatEventLog.GetText: string;
begin
  { needs: string result in EventLog's unmarked interface. }
  Result := TCombatData(TCombatLogbook(F_CombatEventLog_18).F_CombatLogbook_10).F_CombatData_48;
end;

procedure TCombatEventLog.PlayLoggedSFX(A1: Integer);
begin end;

function TCombatEventLog.Execute(Mode: Integer; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
begin end;

procedure TCombatEventLog.ViewLocation(A1: Integer; A2: Integer);
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
  F_CombatViewer_14 := -1;
  FSpeed := 5;
  F_CombatViewer_0C := 5;
end;

destructor TCombatViewer.Destroy;
begin
  if vsInitialized in F_CombatViewer_04 then Finalize;
  TObject(FCombat).Free;
  inherited Destroy;
end;

procedure TCombatViewer.Initialize(A1: Integer);
begin end;

procedure TCombatViewer.Finalize;
begin
  if vsInitialized in F_CombatViewer_04 then
  begin
    TP3CombatDeactivateAccess(FCombat).Deactivate;
    TCombat(FCombat).Clear;
    TCombatLogbook(F_CombatViewer_18).Release;
    F_CombatViewer_18 := 0;
    F_CombatViewer_04 := F_CombatViewer_04 - [vsInitialized];
  end;
end;

function TCombatViewer.GetEndPosition: Integer;
begin Result := TCombatActionList(TCombatLogbook(F_CombatViewer_18).F_CombatLogbook_14).Count + 1; end;

procedure TCombatViewer.SetSpeed(A1: Byte);
begin if A1 = 0 then A1 := 1; FSpeed := A1; end;

procedure TCombatViewer.SetPosition(A1: Integer);
begin end;

procedure TCombatViewer.Play;
begin F_CombatViewer_04 := (F_CombatViewer_04 + [vsPlaying]) - [vsPaused]; end;

procedure TCombatViewer.Pause;
begin F_CombatViewer_04 := F_CombatViewer_04 + [vsPaused]; end;

procedure TCombatViewer.Update;
var Playing: Boolean;
begin
  if (F_CombatViewer_04 * [vsInitialized, vsPlaying, vsPaused] = [vsInitialized, vsPlaying]) and
    (GetEndPosition <> F_CombatViewer_10) then
  begin
    Playing := False;
    if F_CombatViewer_10 = 0 then
    begin
      Inc(F_CombatViewer_14);
      if F_CombatViewer_14 >= F_CombatViewer_0C then
      begin
        F_CombatViewer_10 := 1;
        F_CombatViewer_14 := -1;
      end;
    end;
    while (F_CombatViewer_10 > 0) and
      (F_CombatViewer_10 <= TCombatActionList(TCombatLogbook(F_CombatViewer_18).F_CombatLogbook_14).Count) and not Playing do
    begin
      Inc(F_CombatViewer_14);
      Playing := TP3ActionPlayAccess(TCombatActionList(TCombatLogbook(F_CombatViewer_18).F_CombatLogbook_14).GetCombatActions(F_CombatViewer_10 - 1)).Play(Self);
      if not Playing then
      begin
        Inc(F_CombatViewer_10);
        F_CombatViewer_0C := FSpeed;
        F_CombatViewer_14 := -1;
      end;
    end;
    if GetEndPosition = F_CombatViewer_10 then SetPosition(GetEndPosition);
  end;
end;

procedure TCombatViewer.ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);
begin
  if TCombatActionList(TCombatLogbook(F_CombatViewer_18).F_CombatLogbook_14).Count >= F_CombatViewer_10 then
    TCombatActionList(TCombatLogbook(F_CombatViewer_18).F_CombatLogbook_14).GetCombatActions(F_CombatViewer_10 - 1).ShowObject(Integer(Self), A1, A2, A3, A4, A5, A6)
  else TCombatObject(A1).Show(A2, A3, A4, A5, A6);
end;

procedure TCombatViewer.ShowFieldObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);
begin
  if (F_CombatViewer_10 > 0) and (F_CombatViewer_10 <= TCombatActionList(TCombatLogbook(F_CombatViewer_18).F_CombatLogbook_14).Count) then
    TCombatActionList(TCombatLogbook(F_CombatViewer_18).F_CombatLogbook_14).GetCombatActions(F_CombatViewer_10 - 1).ShowFieldObject(Integer(Self), A1, A2, A3, A4, A5, A6)
  else TCombatObject(A1).Show(A2, A3, A4, A5, A6);
end;

procedure TCombatViewer.ShowFightingObjects(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin
  if (F_CombatViewer_10 > 0) and
    (F_CombatViewer_10 <= TCombatActionList(TCombatLogbook(F_CombatViewer_18).F_CombatLogbook_14).Count) then
    TCombatActionList(TCombatLogbook(F_CombatViewer_18).F_CombatLogbook_14).GetCombatActions(F_CombatViewer_10 - 1).ShowFightingObjects(Integer(Self), A1, A2, A3, A4);
end;

procedure TCombatViewer.DefaultShowFightingObjects(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);
begin
  if A2 <> 0 then
    if TCombatObject(A2).GetSide = csAttacker then ShowObject(A2, A3, 3, A4, A5, A6)
    else ShowObject(A2, A3, 5, A4 + 25, A5, A6);
  if A1 <> 0 then
    if TCombatObject(A1).GetSide = csAttacker then ShowObject(A1, A3, 2, A4, A5 + 15, A6)
    else ShowObject(A1, A3, 6, A4 + 25, A5 + 15, A6);
end;

constructor TCombatAction.Create(AOwner: Engine.TECustomNode);
begin inherited Create(AOwner); F_CombatAction_08 := 1; end;

function TCombatAction.AddRef: Integer;
begin Inc(F_CombatAction_08); Result := F_CombatAction_08; end;

function TCombatAction.Release: Integer;
var N: Integer;
begin
  Dec(F_CombatAction_08);
  N := F_CombatAction_08;
  Result := N;
  if N = 0 then Destroy;
end;

procedure TCombatAction.GetName(A1: Integer);
begin
  { needs: string result; P4 TRangedAttackCA.GetName has an unmarked override. }
  PP3String(A1)^ := ClassName;
end;

procedure TCombatAction.ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin
  TCombatObject(A2).Show(A3, A4, A5, A6, A7);
end;

procedure TCombatAction.ShowFieldObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin
  TCombatObject(A2).Show(A3, A4, A5, A6, A7);
end;

procedure TCombatAction.ShowFightingObjects(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

function TCombatActionList.GetCombatActions(A1: Integer): TCombatAction;
begin Result := TCombatAction(FChildren.List^[A1]); end;

procedure TSingleTargetCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(F_SingleTargetCA_0D, $0A);
  Stream.rwByte(F_SingleTargetCA_0E, $0B);
  Stream.rwData(F_SingleTargetCA_0C, 1, $0C);
end;

function TSingleTargetCA.GetDefensive: Boolean;
begin Result := smDefensive in F_SingleTargetCA_0C; end;

procedure TSingleTargetCA.SetDefensive(A1: Byte);
begin
  if A1 <> 0 then F_SingleTargetCA_0C := F_SingleTargetCA_0C + [smDefensive]
  else F_SingleTargetCA_0C := F_SingleTargetCA_0C - [smDefensive];
end;

procedure TSingleTargetCA.ShowFieldObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

procedure TSingleTargetCA.ShowFightingObjects(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

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
  F_SingleTargetCA_0D := A1;
  F_SingleTargetCA_0E := A2;
  FDamage := A3;
  FEffects.Value := A4;
  FDamageTypes.Value := A5;
  if A6 then F_SingleTargetCA_0C := F_SingleTargetCA_0C + [smDefensive];
end;

procedure TDamageCA.Generate(A1, A2: TCombatObject; A3, A4: Shortint; A5: TDamageTypes);
var DamageTypes: TDamageTypes absolute A5;
begin
  F_SingleTargetCA_0D := TCombatObject(A1).FID;
  F_SingleTargetCA_0E := TCombatObject(A2).FID;
  FDamage := TCombatObject(A2).ExecuteDamageRole(Shortint(A3), Shortint(A4), DamageTypes);
  if FDamage <> 0 then FEffects.Value := TCombatObject(A2).ExecuteDamageEffectsRole(DamageTypes)
  else FEffects.Value := [];
  FDamageTypes.Value := DamageTypes - TCombatObject(A2).GetImmunityTypes;
end;

procedure TDamageCA.GenerateEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);
var DamageTypes: TDamageTypes absolute A5;
begin
  F_SingleTargetCA_0D := TCombatObject(A1).FID;
  F_SingleTargetCA_0E := TCombatObject(A2).FID;
  FDamage := TCombatObject(A2).ExecuteDamageRoleEx(Shortint(A3), Shortint(A4), DamageTypes, Byte(A6));
  if FDamage <> 0 then FEffects.Value := TCombatObject(A2).ExecuteDamageEffectsRole(DamageTypes)
  else FEffects.Value := [];
  FDamageTypes.Value := DamageTypes - TCombatObject(A2).GetImmunityTypes;
end;

procedure TDamageCA.Execute(A1: TCombat; A2: Integer);
var Target, Source: TCombatObject;
begin
  Source := TCombatData(TCombat(A1).FCombatData).FindID(F_SingleTargetCA_0D);
  Target := TCombatData(TCombat(A1).FCombatData).FindID(F_SingleTargetCA_0E);
  if FDamage <> 0 then FDamageDone := Source.DoDamage(Target, FDamage);
  if FEffects.Value <> [] then Target.ExecuteDamageEffects(FEffects.Value);
end;

function TDamageCA.Play(A1: TCombatViewer): Boolean;
var HitFrame, Duration, EffectFrames: Integer; Target: TCombatObject;
begin
  if TCombatViewer(A1).F_CombatViewer_0C < 5 then HitFrame := TCombatViewer(A1).F_CombatViewer_0C else HitFrame := 5;
  if HitFrame = TCombatViewer(A1).F_CombatViewer_14 then
  begin
    Execute(TCombatViewer(A1).FCombat, 0);
    Target := TCombatData(TCombat(TCombatViewer(A1).FCombat).FCombatData).FindID(F_SingleTargetCA_0E);
    if FDamageDone <> 0 then
      if not (csDestroyed in Target.FStatus) then Target.PlaySFX(2) else Target.PlaySFX(3);
  end;
  Duration := TCombatViewer(A1).F_CombatViewer_0C * 2;
  EffectFrames := 0;
  if FEffects.Value <> [] then
  begin
    EffectFrames := TP3DamageFrames(@AoWE.DamageEffectsAnimationFrames)(FEffects.Value) + TCombatViewer(A1).F_CombatViewer_0C;
    if EffectFrames > TCombatViewer(A1).F_CombatViewer_0C * 3 then EffectFrames := TCombatViewer(A1).F_CombatViewer_0C * 3;
    if Duration < EffectFrames then Duration := EffectFrames;
  end;
  { needs: Boolean Play result despite unmarked P4 overrides. }
  asm
    MOV EDX, A1
    MOV EAX, Duration
    CMP [EDX+$14], EAX
    SETL AL
  end;
end;

procedure TDamageCA.ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
var HitFrame: Integer;
begin
  if TCombatObject(A2).FID = F_SingleTargetCA_0D then
    TCombatObject(A2).ShowAttackAnimation(TCombatViewer(A1).F_CombatViewer_14, A4, A5, A6, A7)
  else
  begin
    if TCombatViewer(A1).F_CombatViewer_0C < 5 then HitFrame := TCombatViewer(A1).F_CombatViewer_0C else HitFrame := 5;
    if (TCombatObject(A2).FID = F_SingleTargetCA_0E) and (FDamageDone <> 0) and (HitFrame <= TCombatViewer(A1).F_CombatViewer_14) then
    begin
      TCombatObject(A2).Show(A3, A4, A5, A6, A7);
      if FEffects.Value <> [] then AoWE.ShowDamageEffects(PWord(@FEffects.Value)^, A5, A6, TCombatViewer(A1).F_CombatViewer_14 - HitFrame, A7);
      { needs: P1 ShowDamageIcon has five arguments; DamageTypesToDamageType returns TDamageType. }
      TP3DamageIcon(@AoWE.ShowDamageIcon)(A5, A6, A7, FDamageDone, Ord(TP3DamageType(@AoWE.DamageTypesToDamageType)(FDamageTypes.Value)));
    end
    else TCombatObject(A2).Show(A3, A4, A5, A6, A7);
  end;
end;

class function TDamageEffectCA.ClassID: Integer;
begin Result := $202B2; end;

procedure TDamageEffectCA.ReadWrite(Stream: Engine.TEStorageStream);
begin inherited ReadWrite(Stream); Stream.rwData(F_DamageEffectCA_10, 1, $0F); end;

procedure TDamageEffectCA.Initialize(A1: Byte; A2: Byte; A3: Byte; A4: Boolean);
begin
  F_SingleTargetCA_0D := A1;
  F_SingleTargetCA_0E := A2;
  F_DamageEffectCA_10 := A3;
  if A4 then F_SingleTargetCA_0C := F_SingleTargetCA_0C + [smDefensive];
end;

procedure TDamageEffectCA.Execute(A1: TCombat; A2: Integer);
var Combat: TCombat; Target, Source: TCombatObject;
begin
  Combat := TCombat(A1);
  Target := TCombatData(Combat.FCombatData).FindID(F_SingleTargetCA_0E);
  if not (csDestroyed in Target.FStatus) then
  begin
    Source := TCombatData(Combat.FCombatData).FindID(F_SingleTargetCA_0D);
    Target.ExecuteDamageEffects([TDamageType(F_DamageEffectCA_10)]);
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

procedure TDamageEffectCA.ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

class function TUpdateHeaderCA.ClassID: Integer;
begin Result := $202B6; end;

procedure TUpdateHeaderCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwString(F_UpdateHeaderCA_0C, $14);
end;

procedure TUpdateHeaderCA.Execute(A1: TCombat; A2: Integer);
begin TCombatData(TCombat(A1).FCombatData).F_CombatData_48 := F_UpdateHeaderCA_0C; end;

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

procedure TNewCombatTurnCA.Execute(A1: TCombat; A2: Integer);
var I: Integer;
begin
  TCombatData(TCombat(A1).FCombatData).F_CombatData_31 := F_NewCombatTurnCA_0C;
  for I := TCombatData(TCombat(A1).FCombatData).GetCount - 1 downto 0 do
    TCombatData(TCombat(A1).FCombatData).GetObjects(I).NewTurn(F_NewCombatTurnCA_0C);
end;

function TNewCombatTurnCA.Play(A1: TCombatViewer): Boolean;
{ needs: Boolean Play result despite the unmarked P4 overrides. }
asm
  PUSH EBX
  MOV EBX, EDX
  CMP DWORD PTR [EBX+$14], 0
  JNE @@Playing
  MOV EDX, [EBX+8]
  MOV ECX, [EAX]
  CALL DWORD PTR [ECX+$50]
  MOV EAX, OFFSET P3InfoSample + 8
  CALL Sound.PlaySample
@@Playing:
  XOR EAX, EAX
  MOV AL, [EBX+$0C]
  CMP EAX, [EBX+$14]
  SETG AL
  POP EBX
end;

class function TNewCombatRoundCA.ClassID: Integer;
begin Result := $202BB; end;

procedure TNewCombatRoundCA.Execute(A1: TCombat; A2: Integer);
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

procedure TCombatObjectTurnDoneCA.Execute(A1: TCombat; A2: Integer);
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

procedure TMoveWallCA.Execute(A1: TCombat; A2: Integer);
var Obj: TP3FastStateView;
begin
  Obj := TP3FastStateView(TCombatData(TCombat(A1).FCombatData).FindID(F_MoveWallCA_0C));
  if F_MoveWallCA_0D = 0 then Obj.State := Obj.State + [fsOutsideWall];
  if F_MoveWallCA_0D = 1 then Obj.State := Obj.State - [fsOutsideWall];
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

procedure TFleeCA.Execute(A1: TCombat; A2: Integer);
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
begin inherited Create; F_CombatPredictorUnit_34 := Integer(TQuadItemList.Create); end;

destructor TCombatPredictorUnit.Destroy;
var Obj: TObject; U: TAbstractUnit;
begin
  TObject(F_CombatPredictorUnit_34).Free;
  Obj := TObject(F_CombatPredictorUnit_20);
  if Obj <> nil then begin Obj.Free; F_CombatPredictorUnit_20 := 0; end;
  Obj := TObject(F_CombatPredictorUnit_28);
  if Obj <> nil then begin Obj.Free; F_CombatPredictorUnit_28 := 0; end;
  U := TAbstractUnit(F_CombatPredictorUnit_04);
  if U <> nil then begin U.Release; F_CombatPredictorUnit_04 := 0; end;
  inherited Destroy;
end;

procedure TCombatPredictorUnit.Setup(A1: Integer; A2: Integer; A3: Byte);
var Predictor: TCombatPredictor absolute A2; P: TCombatPredictor; U: TAbstractUnit;
begin
  U := TAbstractUnit(A1);
  F_CombatPredictorUnit_04 := Integer(U);
  U.AddRef;
  P := Predictor;
  F_CombatPredictorUnit_0C := Integer(P);
  F_CombatPredictorUnit_08 := P.CreateUniqueCPUID;
  F_CombatPredictorUnit_14 := A3;
  { needs: P2 GetHitPoints returns Shortint; MOVSX AL at $5572A61F. }
  F_CombatPredictorUnit_10 := TP3AbstractUnitAccess(F_CombatPredictorUnit_04).HitPoints * 100;
  F_CombatPredictorUnit_1C := 1;
  F_CombatPredictorUnit_30 := 1;
  F_CombatPredictorUnit_31 := 1;
  if F_CombatPredictorUnit_14 = 0 then F_CombatPredictorUnit_18 := TCombatPredictor(F_CombatPredictorUnit_0C).FSides[1]
  else F_CombatPredictorUnit_18 := TCombatPredictor(F_CombatPredictorUnit_0C).FSides[0];
end;

procedure TCombatPredictorUnit.SetEnabled(A1: Byte);
begin
  if A1 <> F_CombatPredictorUnit_1C then
  begin
    F_CombatPredictorUnit_1C := A1;
    TCombatPredictor(F_CombatPredictorUnit_0C).F_CombatPredictor_2C := 1;
  end;
end;

procedure TCombatPredictorUnit.UpdateTargets;
var I, J, V: Integer; U: TCombatPredictorUnit;
begin
  if F_CombatPredictorUnit_20 = 0 then F_CombatPredictorUnit_20 := Integer(TQuadItemList.Create);
  for I := TQuadItemList(F_CombatPredictorUnit_20).Count - 1 downto 0 do
  begin
    J := TCombatPredictorUnitList(F_CombatPredictorUnit_18).IndexOfCPUID(TQuadItemList(F_CombatPredictorUnit_20).List^[I].C);
    if J = -1 then
    begin
      TQuadItemList(F_CombatPredictorUnit_20).Delete(I);
      { Original reads the shifted entry after deletion. }
      Dec(F_CombatPredictorUnit_24, TQuadItemList(F_CombatPredictorUnit_20).List^[I].B);
    end;
  end;
  if TQuadItemList(F_CombatPredictorUnit_20).Count <> 0 then
    for I := TCombatPredictorUnitList(F_CombatPredictorUnit_18).Count - 1 downto 0 do
    begin
      U := TCombatPredictorUnitList(F_CombatPredictorUnit_18).GetUnits(I);
      J := TQuadItemList(F_CombatPredictorUnit_20).IndexOfItemC(U.F_CombatPredictorUnit_08);
      if J = -1 then
      begin
        Inc(TCombatPredictor(F_CombatPredictorUnit_0C).F_CombatPredictor_30);
        V := TP3CombatValue(@TAbstractUnit.GetCombatValue)(TAbstractUnit(F_CombatPredictorUnit_04), U.F_CombatPredictorUnit_04, 0);
        if V < 0 then V := 0;
        TQuadItemList(F_CombatPredictorUnit_20).AddABCD(Integer(U), V, 0, U.F_CombatPredictorUnit_08);
        Inc(F_CombatPredictorUnit_24, V);
      end;
    end
  else
  begin
    F_CombatPredictorUnit_24 := 0;
    for I := TCombatPredictorUnitList(F_CombatPredictorUnit_18).Count - 1 downto 0 do
    begin
      Inc(TCombatPredictor(F_CombatPredictorUnit_0C).F_CombatPredictor_30);
      U := TCombatPredictorUnit(TCombatPredictorUnitList(F_CombatPredictorUnit_18).List^[I]);
      V := TP3CombatValue(@TAbstractUnit.GetCombatValue)(TAbstractUnit(F_CombatPredictorUnit_04), U.F_CombatPredictorUnit_04, 0);
      if V < 0 then V := 0;
      { Original stores CPUID in D although the cache lookup reads C. }
      TQuadItemList(F_CombatPredictorUnit_20).AddABCD(Integer(U), V, 0, U.F_CombatPredictorUnit_08);
      Inc(F_CombatPredictorUnit_24, V);
    end;
  end;
  F_CombatPredictorUnit_30 := 0;
end;

procedure TCombatPredictorUnit.UpdateWallTargets;
var I, J, V: Integer; U: TCombatPredictorUnit; Passing: Boolean; Mode: Byte;
begin
  Passing := wcWallPassing in TP3AbstractUnitAccess(F_CombatPredictorUnit_04).WallFeatures;
  if F_CombatPredictorUnit_28 = 0 then F_CombatPredictorUnit_28 := Integer(TQuadItemList.Create);
  for I := TQuadItemList(F_CombatPredictorUnit_28).Count - 1 downto 0 do
  begin
    J := TCombatPredictorUnitList(F_CombatPredictorUnit_18).IndexOfCPUID(TQuadItemList(F_CombatPredictorUnit_28).List^[I].C);
    if J = -1 then
    begin
      TQuadItemList(F_CombatPredictorUnit_28).Delete(I);
      { Original reads the shifted entry after deletion. }
      Dec(F_CombatPredictorUnit_2C, TQuadItemList(F_CombatPredictorUnit_28).List^[I].B);
    end;
  end;
  if TQuadItemList(F_CombatPredictorUnit_28).Count <> 0 then
    for I := TCombatPredictorUnitList(F_CombatPredictorUnit_18).Count - 1 downto 0 do
    begin
      U := TCombatPredictorUnit(TCombatPredictorUnitList(F_CombatPredictorUnit_18).List^[I]);
      J := TQuadItemList(F_CombatPredictorUnit_28).IndexOfItemC(U.F_CombatPredictorUnit_08);
      if J = -1 then
      begin
        if Passing then Mode := 0
        else if F_CombatPredictorUnit_1D <> 0 then
          if U.F_CombatPredictorUnit_1D = 0 then Mode := 1 else Mode := 0
        else if U.F_CombatPredictorUnit_1D <> 0 then Mode := 2 else Mode := 0;
        Inc(TCombatPredictor(F_CombatPredictorUnit_0C).F_CombatPredictor_30);
        V := TP3CombatValue(@TAbstractUnit.GetCombatValue)(TAbstractUnit(F_CombatPredictorUnit_04), U.F_CombatPredictorUnit_04, Mode);
        if V < 0 then V := 0;
        TQuadItemList(F_CombatPredictorUnit_28).AddABCD(Integer(U), V, 0, 0);
        Inc(F_CombatPredictorUnit_2C, V);
      end;
    end
  else
  begin
    F_CombatPredictorUnit_2C := 0;
    for I := TCombatPredictorUnitList(F_CombatPredictorUnit_18).Count - 1 downto 0 do
    begin
      U := TCombatPredictorUnit(TCombatPredictorUnitList(F_CombatPredictorUnit_18).List^[I]);
      if Passing then Mode := 0
      else if F_CombatPredictorUnit_1D <> 0 then
        if U.F_CombatPredictorUnit_1D = 0 then Mode := 1 else Mode := 0
      else if U.F_CombatPredictorUnit_1D <> 0 then Mode := 2 else Mode := 0;
      Inc(TCombatPredictor(F_CombatPredictorUnit_0C).F_CombatPredictor_30);
      V := TP3CombatValue(@TAbstractUnit.GetCombatValue)(TAbstractUnit(F_CombatPredictorUnit_04), U.F_CombatPredictorUnit_04, Mode);
      if V < 0 then V := 0;
      { Original initializes both C and D to zero in the wall cache. }
      TQuadItemList(F_CombatPredictorUnit_28).AddABCD(Integer(U), V, 0, 0);
      Inc(F_CombatPredictorUnit_2C, V);
    end;
  end;
  F_CombatPredictorUnit_31 := 0;
end;

procedure TCombatPredictorUnit.InvalidateTargets;
begin F_CombatPredictorUnit_30 := 1; F_CombatPredictorUnit_31 := 1; end;

procedure TCombatPredictorUnit.ResetCombat;
begin
  F_CombatPredictorUnit_4C := F_CombatPredictorUnit_10;
  F_CombatPredictorUnit_3C := 0;
  F_CombatPredictorUnit_50 := [];
end;

procedure TCombatPredictorUnit.ResetRoundTargets;
begin
  TQuadItemList(F_CombatPredictorUnit_34).Clear;
  F_CombatPredictorUnit_38 := 0;
  F_CombatPredictorUnit_40 := 0;
  F_CombatPredictorUnit_44 := 0;
end;

procedure TCombatPredictorUnit.SetupRoundTargets(A1: Byte);
var I, V: Integer; U: TCombatPredictorUnit; Q: TQuadItemList;
begin
  if F_CombatPredictorUnit_1C <> 0 then
  begin
    if A1 <> 0 then
    begin
      if F_CombatPredictorUnit_31 <> 0 then UpdateWallTargets;
      TQuadItemList(F_CombatPredictorUnit_34).Assign(TQuadItemList(F_CombatPredictorUnit_28));
    end
    else
    begin
      if F_CombatPredictorUnit_30 <> 0 then UpdateTargets;
      TQuadItemList(F_CombatPredictorUnit_34).Assign(TQuadItemList(F_CombatPredictorUnit_20));
    end;
    for I := TQuadItemList(F_CombatPredictorUnit_34).Count - 1 downto 0 do
    begin
      Q := TQuadItemList(F_CombatPredictorUnit_34);
      U := TCombatPredictorUnit(Q.List^[I].A);
      if U.F_CombatPredictorUnit_1C <> 0 then
      begin
        V := TQuadItemList(F_CombatPredictorUnit_34).List^[I].B;
        if V > 0 then
        begin
          Inc(U.F_CombatPredictorUnit_40, V);
          Inc(F_CombatPredictorUnit_38, V);
        end
        else
        begin
          Inc(U.F_CombatPredictorUnit_44);
          TQuadItemList(F_CombatPredictorUnit_34).Delete(I);
        end;
      end
      else Q.Delete(I);
    end;
  end;
end;

procedure TCombatPredictorUnit.UpdateRoundTargetPriority;
var I: Integer;
begin
  if F_CombatPredictorUnit_1C <> 0 then
  begin
    F_CombatPredictorUnit_48 := 0;
    for I := TQuadItemList(F_CombatPredictorUnit_34).Count - 1 downto 0 do
      Inc(F_CombatPredictorUnit_48, TCombatPredictorUnit(TQuadItemList(F_CombatPredictorUnit_34).List^[I].A).F_CombatPredictorUnit_44);
  end
  else F_CombatPredictorUnit_48 := 0;
end;

function P3CompareRoundTargets(const A, B: TQuadItem): Integer;
begin Result := A.D - B.D; end;

procedure TCombatPredictorUnit.SortRoundTargets;
var I, V, Priority: Integer; U: TCombatPredictorUnit;
begin
  for I := TQuadItemList(F_CombatPredictorUnit_34).Count - 1 downto 0 do
  begin
    U := TCombatPredictorUnit(TQuadItemList(F_CombatPredictorUnit_34).List^[I].A);
    V := TQuadItemList(F_CombatPredictorUnit_34).List^[I].B;
    if U.F_CombatPredictorUnit_38 <> 0 then
      Priority := (V * 100 * 1000) div U.F_CombatPredictorUnit_40 + U.F_CombatPredictorUnit_48 * 100 + V
    else Priority := 0;
    TQuadItemList(F_CombatPredictorUnit_34).List^[I].D := Priority;
  end;
  TQuadItemList(F_CombatPredictorUnit_34).Sort(P3CompareRoundTargets);
end;

function TCombatPredictorUnit.ExecuteRound: Boolean;
var I: Integer; U: TCombatPredictorUnit;
begin
  I := TQuadItemList(F_CombatPredictorUnit_34).Count;
  Result := False;
  if I <> 0 then Inc(F_CombatPredictorUnit_3C);
  while (I <> 0) and not Result do
  begin
    Dec(I);
    U := TCombatPredictorUnit(TQuadItemList(F_CombatPredictorUnit_34).List^[I].A);
    if U.F_CombatPredictorUnit_4C > 0 then
    begin
      Dec(U.F_CombatPredictorUnit_4C, TQuadItemList(F_CombatPredictorUnit_34).List^[I].B);
      Result := True;
    end
    else TQuadItemList(F_CombatPredictorUnit_34).Delete(I);
  end;
end;

procedure TCombatPredictorUnit.FinishCombat;
begin if F_CombatPredictorUnit_4C <= 0 then F_CombatPredictorUnit_50 := F_CombatPredictorUnit_50 + [usDestroyed]; end;

function TCombatPredictorUnitList.GetUnits(A1: Integer): TCombatPredictorUnit;
begin Result := TCombatPredictorUnit(List^[A1]); end;

function TCombatPredictorUnitList.IndexOfUnit(A1: Integer): Integer;
begin
  Result := Count;
  while Result <> 0 do
  begin
    Dec(Result);
    if TCombatPredictorUnit(List^[Result]).F_CombatPredictorUnit_04 = A1 then Exit;
  end;
  Result := -1;
end;

function TCombatPredictorUnitList.IndexOfCPUID(A1: Integer): Integer;
begin
  Result := Count;
  while Result <> 0 do
  begin
    Dec(Result);
    if TCombatPredictorUnit(List^[Result]).F_CombatPredictorUnit_08 = A1 then Exit;
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
  F_CombatPredictor_04 := Integer(TCombatPredictorUnitList.Create);
  F_CombatPredictor_08 := Integer(TCombatPredictorUnitList.Create);
  FSides[0] := Integer(TCombatPredictorSide.Create);
  FSides[1] := Integer(TCombatPredictorSide.Create);
end;

destructor TCombatPredictor.Destroy;
begin
  Reset;
  TObject(F_CombatPredictor_04).Free;
  TObject(F_CombatPredictor_08).Free;
  TObject(FSides[0]).Free;
  TObject(FSides[1]).Free;
  inherited Destroy;
end;

procedure TCombatPredictor.Reset;
var I: Integer;
begin
  for I := TList(F_CombatPredictor_04).Count - 1 downto 0 do TObject(TList(F_CombatPredictor_04).List^[I]).Free;
  F_CombatPredictor_20 := 0;
  TList(F_CombatPredictor_04).Count := 0;
  TList(F_CombatPredictor_08).Count := 0;
  TList(FSides[0]).Count := 0;
  TList(FSides[1]).Count := 0;
  F_CombatPredictor_18 := -1;
  F_CombatPredictor_1C := -1;
  F_CombatPredictor_28 := 0;
end;

function TCombatPredictor.CreateUniqueCPUID: Integer;
begin Result := F_CombatPredictor_28; Inc(F_CombatPredictor_28); end;

procedure TCombatPredictor.EnableAllUnits;
var I: Integer;
begin
  for I := TList(F_CombatPredictor_04).Count - 1 downto 0 do
    if TCombatPredictorUnit(TList(F_CombatPredictor_04).List^[I]).F_CombatPredictorUnit_1C = 0 then
    begin
      TCombatPredictorUnit(TList(F_CombatPredictor_04).List^[I]).F_CombatPredictorUnit_1C := 1;
      F_CombatPredictor_2C := 1;
    end;
end;

procedure TCombatPredictor.Validate;
begin if F_CombatPredictor_2C <> 0 then Execute; end;

procedure TCombatPredictor.ResetCombat;
var I: Integer;
begin
  F_CombatPredictor_2C := 1;
  F_CombatPredictor_18 := -1;
  F_CombatPredictor_1C := -1;
  F_CombatPredictor_24 := 0;
  for I := TList(F_CombatPredictor_04).Count - 1 downto 0 do TCombatPredictorUnit(TList(F_CombatPredictor_04).List^[I]).ResetCombat;
end;

procedure TCombatPredictor.SetupCombat(A1: Byte);
var I: Integer; U: TCombatPredictorUnit;
begin
  TList(F_CombatPredictor_08).Clear;
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
  for I := TList(F_CombatPredictor_04).Count - 1 downto 0 do TCombatPredictorUnit(TList(F_CombatPredictor_04).List^[I]).ResetRoundTargets;
  for I := TList(F_CombatPredictor_04).Count - 1 downto 0 do TCombatPredictorUnit(TList(F_CombatPredictor_04).List^[I]).SetupRoundTargets(Byte(A1));
  for I := TList(F_CombatPredictor_04).Count - 1 downto 0 do TCombatPredictorUnit(TList(F_CombatPredictor_04).List^[I]).UpdateRoundTargetPriority;
  for I := TList(F_CombatPredictor_04).Count - 1 downto 0 do
  begin
    U := TCombatPredictorUnit(TList(F_CombatPredictor_04).List^[I]);
    if (U.F_CombatPredictorUnit_1C <> 0) and (TQuadItemList(U.F_CombatPredictorUnit_34).Count <> 0) then
    begin
      U.SortRoundTargets;
      TList(F_CombatPredictor_08).Add(U);
    end;
  end;
end;

function TCombatPredictor.ExecuteCombatRound: Boolean;
var U: TCombatPredictorUnit; I: Integer;
begin
  Result := False;
  for I := TList(F_CombatPredictor_08).Count - 1 downto 0 do
  begin
    U := TCombatPredictorUnit(TList(F_CombatPredictor_08).List^[I]);
    if U.ExecuteRound then Result := True
    else TList(F_CombatPredictor_08).Delete(I);
  end;
  for I := TList(F_CombatPredictor_08).Count - 1 downto 0 do
  begin
    U := TCombatPredictorUnit(TList(F_CombatPredictor_08).List^[I]);
    if U.F_CombatPredictorUnit_4C < 1 then TList(F_CombatPredictor_08).Delete(I);
  end;
  if Result then Inc(F_CombatPredictor_24);
end;

function TCombatPredictor.CanPassWall: Boolean;
var I: Integer;
begin
  try
    Result := False;
    I := TList(F_CombatPredictor_04).Count;
    while not Result and (I <> 0) do
    begin
      Dec(I);
      if TCombatPredictorUnitList(F_CombatPredictor_04).GetUnits(I).F_CombatPredictorUnit_04 <> 0 then
        Result := wcWallPassing in TP3AbstractUnitAccess(TCombatPredictorUnitList(F_CombatPredictor_04).GetUnits(I).F_CombatPredictorUnit_04).WallFeatures;
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
  for I := TList(F_CombatPredictor_04).Count - 1 downto 0 do
  begin
    U := TCombatPredictorUnit(TList(F_CombatPredictor_04).List^[I]);
    U.FinishCombat;
    if not (usDestroyed in U.F_CombatPredictorUnit_50) then Inc(Surviving[U.F_CombatPredictorUnit_14]);
    Inc(Hits[U.F_CombatPredictorUnit_14], U.F_CombatPredictorUnit_4C);
  end;
  if (Surviving[1] = 0) and (Surviving[0] = 0) then
    if Hits[0] >= Hits[1] then F_CombatPredictor_14 := 3 else F_CombatPredictor_14 := 4
  else if Surviving[1] = 0 then F_CombatPredictor_14 := 3
  else
  begin
    Wall := TCombatPredictorUnit(F_CombatPredictor_20);
    if (Wall <> nil) and (Wall.F_CombatPredictorUnit_4C > 0) then
      if (Surviving[1] = 1) and CanPassWall then F_CombatPredictor_14 := 3 else F_CombatPredictor_14 := 8
    else if Surviving[0] = 0 then F_CombatPredictor_14 := 4 else F_CombatPredictor_14 := 2;
  end;
  TList(F_CombatPredictor_08).Clear;
end;

procedure TCombatPredictor.Execute;
begin end;

procedure TCombatPredictor.DeleteUnit(A1: Integer);
var I, J: Integer; U: TCombatPredictorUnit; D: TDamageType;
begin
  I := TCombatPredictorUnitList(F_CombatPredictor_04).IndexOfUnit(A1);
  if I <> -1 then
  begin
    U := TCombatPredictorUnitList(F_CombatPredictor_04).GetUnits(I);
    J := TCombatPredictorUnitList(FSides[U.F_CombatPredictorUnit_14]).IndexOfUnit(A1);
    if J <> -1 then
    begin
      if Integer(TCombatPredictorUnitList(FSides[U.F_CombatPredictorUnit_14]).GetUnits(J)) = F_CombatPredictor_20 then F_CombatPredictor_20 := 0;
      TList(FSides[U.F_CombatPredictorUnit_14]).Delete(J);
      TCombatPredictorSide(FSides[U.F_CombatPredictorUnit_14]).F_CombatPredictorSide_10[0] := 1;
      { Original adds strength when deleting a unit. }
      for D := Low(TDamageType) to High(TDamageType) do
        Inc(TCombatPredictorSide(FSides[U.F_CombatPredictorUnit_14]).FStrength[D], TP3UnitStrength(@TAbstractUnit.GetStrength)(TAbstractUnit(A1), D));
    end;
    F_CombatPredictor_2C := 1;
    TList(F_CombatPredictor_04).Delete(I);
    U.Free;
  end;
end;

function TCombatPredictor.AddUnitEx(A1: Integer; A2: Byte; A3: Byte): TCombatPredictorUnit;
var U: TCombatPredictorUnit; D: TDamageType;
begin
  U := TCombatPredictorUnit.Create;
  U.Setup(A1, Integer(Self), A2);
  U.F_CombatPredictorUnit_1D := A3;
  TList(F_CombatPredictor_04).Add(U);
  TList(FSides[A2]).Add(U);
  TCombatPredictorSide(FSides[A2]).F_CombatPredictorSide_10[0] := 1;
  for D := Low(TDamageType) to High(TDamageType) do
    Inc(TCombatPredictorSide(FSides[A2]).FStrength[D], TP3UnitStrength(@TAbstractUnit.GetStrength)(TAbstractUnit(A1), D));
  F_CombatPredictor_2C := 1;
  Result := U;
end;

procedure TCombatPredictor.AddUnit(A1: Integer);
begin AddUnitEx(A1, 0, 0); end;

procedure TCombatPredictor.AddUnits(A1: Integer);
var I: Integer;
begin
  for I := 0 to TUnitList(A1).Count - 1 do
    AddUnit(Integer(TP3GetUnit(@TUnitList.GetUnit)(TUnitList(A1), I)));
end;

procedure TCombatPredictor.AddOpponent(A1: Integer; A2: Integer);
begin AddUnitEx(A1, 1, Byte(A2)); end;

procedure TCombatPredictor.AddOpponents(A1: Integer; A2: Byte);
var I: Integer;
begin
  for I := 0 to TUnitList(A1).Count - 1 do
    AddOpponent(Integer(TP3GetUnit(@TUnitList.GetUnit)(TUnitList(A1), I)), A2);
end;

procedure TCombatPredictor.AddWall(A1: Integer);
begin end;

procedure TCombatPredictor.DeleteWall;
var Wall: TCombatPredictorUnit;
begin
  Wall := TCombatPredictorUnit(F_CombatPredictor_20);
  if Wall <> nil then
  begin
    DeleteUnit(Wall.F_CombatPredictorUnit_04);
    F_CombatPredictor_20 := 0;
  end;
end;

procedure TCombatPredictor.DeleteUnits;
var I: Integer;
begin
  for I := TList(FSides[0]).Count - 1 downto 0 do
    DeleteUnit(TCombatPredictorUnitList(FSides[0]).GetUnits(I).F_CombatPredictorUnit_04);
end;

procedure TCombatPredictor.DeleteOpponents;
var I: Integer;
begin
  for I := TList(FSides[1]).Count - 1 downto 0 do
    DeleteUnit(TCombatPredictorUnitList(FSides[1]).GetUnits(I).F_CombatPredictorUnit_04);
end;

procedure TCombatPredictor.InitAdjacentArmies(A1: Integer; A2: Byte; A3: Integer; A4: Integer);
begin end;

procedure TCombatPredictor.InitAdjacentOpponents(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
begin end;

function TCombatPredictor.GetSuperiority: Integer;
var U, Opponent: TCombatPredictorUnit; Left, Total, I: Integer;
begin
  if F_CombatPredictor_18 = -1 then
    case F_CombatPredictor_14 of
      3:
        begin
          Total := 0; Left := 0;
          for I := TList(FSides[0]).Count - 1 downto 0 do
          begin
            U := TCombatPredictorUnit(TList(FSides[0]).List^[I]);
            Inc(Total, U.F_CombatPredictorUnit_38);
            if U.F_CombatPredictorUnit_4C > 0 then Inc(Left, U.F_CombatPredictorUnit_4C * U.F_CombatPredictorUnit_38 div U.F_CombatPredictorUnit_10);
          end;
          if Total = Left then F_CombatPredictor_18 := 999
          else if Left < 1 then F_CombatPredictor_18 := 100
          else F_CombatPredictor_18 := Total * 100 div (Total - Left);
        end;
      2, 4, 8:
        begin
          Total := 0; Left := 0;
          for I := TList(FSides[1]).Count - 1 downto 0 do
          begin
            Opponent := TCombatPredictorUnit(TList(FSides[1]).List^[I]);
            Inc(Total, Opponent.F_CombatPredictorUnit_38);
            if Opponent.F_CombatPredictorUnit_4C > 0 then Inc(Left, Opponent.F_CombatPredictorUnit_4C * Opponent.F_CombatPredictorUnit_38 div Opponent.F_CombatPredictorUnit_10);
          end;
          if Total = 0 then F_CombatPredictor_18 := 0
          else if Left < 1 then F_CombatPredictor_18 := 100
          else F_CombatPredictor_18 := (Total - Left) * 100 div Total;
        end;
      6: F_CombatPredictor_18 := 200;
    else F_CombatPredictor_18 := 0;
    end;
  Result := F_CombatPredictor_18;
end;

function TCombatPredictor.GetEfficiency: Integer;
var Lost: array[0..1] of Integer; Side: Byte; I: Integer; U: TCombatPredictorUnit;
begin
  if F_CombatPredictor_1C = -1 then
  begin
    for Side := 0 to 1 do
    begin
      Lost[Side] := 0;
      for I := TList(FSides[Side]).Count - 1 downto 0 do
      begin
        U := TCombatPredictorUnit(TList(FSides[Side]).List^[I]);
        if usDestroyed in U.F_CombatPredictorUnit_50 then
          Inc(Lost[Side], TP3AbstractUnitAccess(U.F_CombatPredictorUnit_04).ObtainValue)
        else if U.F_CombatPredictorUnit_4C < U.F_CombatPredictorUnit_10 then
          Inc(Lost[Side], Round((TP3AbstractUnitAccess(U.F_CombatPredictorUnit_04).ObtainValue * U.F_CombatPredictorUnit_4C) / (U.F_CombatPredictorUnit_10 * 2)));
      end;
    end;
    if Lost[0] <> 0 then F_CombatPredictor_1C := Lost[1] * 100 div Lost[0]
    else if (Lost[1] <> 0) or (TList(FSides[1]).Count = 0) then F_CombatPredictor_1C := 999
    else F_CombatPredictor_1C := 100;
  end;
  Result := F_CombatPredictor_1C;
end;

procedure TCombatPredictor.ListRequiredUnitsEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TCombatPredictor.ListRequiredUnits(A1: Integer; A2: Integer);
begin ListRequiredUnitsEx(A1, 0, 0, A2); end;

procedure TCombatPredictor.ListOptionalUnits(A1: Integer; A2: Integer);
begin ListRequiredUnitsEx(0, A1, 0, A2); end;

procedure TCombatPredictor.ListUselessUnits(A1: Integer);
var I: Integer; U: TCombatPredictorUnit;
begin
  for I := TList(FSides[0]).Count - 1 downto 0 do
  begin
    U := TCombatPredictorUnit(TList(FSides[0]).List^[I]);
    if U.F_CombatPredictorUnit_38 <= 0 then TUnitList(A1).AddUnit(TAbstractUnit(U.F_CombatPredictorUnit_04));
  end;
end;

function TCombatPredictor.Usefullness(A1: Integer): Integer;
var Wall, U, Target: TCombatPredictorUnit; I: Integer; AllDead, Useful: Boolean;
begin
  EnableAllUnits;
  Validate;
  U := TCombatPredictorUnit.Create;
  U.Setup(A1, Integer(Self), 0);
  Wall := TCombatPredictorUnit(F_CombatPredictor_20);
  if (Wall <> nil) and (Wall.F_CombatPredictorUnit_4C > 0) then
  begin
    U.UpdateWallTargets;
    Result := U.F_CombatPredictorUnit_2C;
    Useful := False;
    I := TQuadItemList(U.F_CombatPredictorUnit_28).Count;
    while (I <> 0) and not Useful do
    begin
      Dec(I);
      if TQuadItemList(U.F_CombatPredictorUnit_28).List^[I].B > 0 then
      begin
        Target := TCombatPredictorUnit(TQuadItemList(U.F_CombatPredictorUnit_28).List^[I].A);
        Useful := (Target = TCombatPredictorUnit(F_CombatPredictor_20)) and (Target.F_CombatPredictorUnit_4C > 0);
      end;
    end;
    if Useful then Result := Result or $800000;
  end
  else
  begin
    U.UpdateTargets;
    Result := U.F_CombatPredictorUnit_24;
    I := TList(FSides[0]).Count;
    AllDead := True;
    while (I <> 0) and AllDead do
    begin
      Dec(I);
      AllDead := usDestroyed in TCombatPredictorUnitList(FSides[0]).GetUnits(I).F_CombatPredictorUnit_50;
    end;
    Useful := False;
    I := TQuadItemList(U.F_CombatPredictorUnit_20).Count;
    while (I <> 0) and not Useful do
    begin
      Dec(I);
      if TQuadItemList(U.F_CombatPredictorUnit_20).List^[I].B > 0 then
      begin
        Target := TCombatPredictorUnit(TQuadItemList(U.F_CombatPredictorUnit_20).List^[I].A);
        Useful := (Target <> TCombatPredictorUnit(F_CombatPredictor_20)) and
          ((Target.F_CombatPredictorUnit_4C > 0) or (F_CombatPredictor_14 = 3) or AllDead);
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
