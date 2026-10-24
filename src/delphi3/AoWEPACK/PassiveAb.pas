unit PassiveAb;

{ Draft declarations of PassiveAb, from AoWEPACK.dpl.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  All class bodies and the registration routines are recovered. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, GFXE, ImageLib, Sound, NetworkE, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, AoWE;

type
  TVisionAbility = class;
  THolyChampionAbility = class;
  TUnholyChampionAbility = class;
  TNaturesBlessingAbility = class;
  THighPrayerBlessingAbility = class;
  TCrusaderAbility = class;
  TBloodlustAbility = class;
  TPoisonedAbility = class;
  TDecayAbility = class;
  TWebbedAbility = class;
  TStunnedAbility = class;
  TBurningAbility = class;
  TVertigoAbility = class;
  TCursedAbility = class;
  THolyFear = class;
  TPanickedAbility = class;
  TWallClimbingAbility = class;
  TPassWallAbility = class;
  TResurrectedAbility = class;
  TAnimatedAbility = class;
  TCombatResurrectedAbility = class;
  TMarksmanshipAbility = class;
  TMovementAbility = class;
  TImmunityAbility = class;
  TProtectionAbility = class;
  TEntangledAbility = class;
  TFrozenAbility = class;
  TTurnedUndeadAbility = class;
  THasteAbility = class;
  TStoneSkinAbility = class;
  TEnchantedWeaponAbility = class;
  TSummonedAbility = class;
  TFuryAbility = class;
  TFreeMovementAbility = class;
  THolyChampionEnchantment = class;
  TUnholyChampionEnchantment = class;
  TConcealmentEnchantment = class;
  TFireAuraEnchantment = class;
  TWaterWalkingEnchantment = class;
  TWindWalkingEnchantment = class;
  TLiquidFormEnchantment = class;
  TBlessedEnchantment = class;
  TDarkGiftEnchantment = class;
  TFireProtectionEnchantment = class;
  TSlowEnchantmentAbility = class;


  { TVisionAbility (instance size 48, VMT 557B502C):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type;
    $28 maximum level, $2C level costs. }
  TVisionAbility = class(TMultiLevelAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetLevelName(A1: Integer): string; override;
  end;

  { THolyChampionAbility (instance size 40, VMT 557B51B8):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type. }
  THolyChampionAbility = class(TEnhancementAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CanExpand(A1: TAbilityOwner): Boolean; override;
  end;

  { TUnholyChampionAbility (instance size 40, VMT 557B534C):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type. }
  TUnholyChampionAbility = class(TEnhancementAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CanExpand(A1: TAbilityOwner): Boolean; override;
  end;

  { TNaturesBlessingAbility (instance size 44, VMT 557B54E4):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type; $28 duration mode. }
  TNaturesBlessingAbility = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetAttack(A1: TAbilityOwner): Shortint; override;
    function GetDefense(A1: TAbilityOwner): Shortint; override;
    function GetResistance(A1: TAbilityOwner): Shortint; override;
    function Expand(A1: TAbilityOwner): Boolean; override;
  end;

  { THighPrayerBlessingAbility (instance size 44; $08 name, $0C ID, $20 selection types, $24 ability type, $28 duration mode; VMT 557B5684) }
  THighPrayerBlessingAbility = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetDefense(A1: TAbilityOwner): Shortint; override;
    function GetResistance(A1: TAbilityOwner): Shortint; override;
  end;

  { TCrusaderAbility (instance size 44, VMT 557B582C):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type,
    $28 duration mode; duration data $0C countdown, $0D player index. }
  TCrusaderAbility = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure NewTurn(A1: TAbilityOwner; A2: Shortint); override;
    function Remove(A1: TAbilityOwner): Boolean; override;
    function GetTotalDuration: Integer; override;
  end;

  { TBloodlustAbility (instance size 44, VMT 557B59C0):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type; $28 duration mode. }
  TBloodlustAbility = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetAttack(A1: TAbilityOwner): Shortint; override;
    function GetDefense(A1: TAbilityOwner): Shortint; override;
    function GetDamage(A1: TAbilityOwner): Shortint; override;
  end;

  { TPoisonedAbility (instance size 44, VMT 557B5B58):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type; $28 duration mode. }
  TPoisonedAbility = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetAttack(A1: TAbilityOwner): Shortint; override;
    function GetDefense(A1: TAbilityOwner): Shortint; override;
    function GetResistance(A1: TAbilityOwner): Shortint; override;
    function GetDamage(A1: TAbilityOwner): Shortint; override;
  end;

  { TDecayAbility (instance size 44, VMT 557B5CEC):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type, $28 duration mode. }
  TDecayAbility = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure NewCombatTurn(A1: TCombatObject; A2: Shortint); override;
    procedure CombatDone(A1: TCombatObject); override;
  end;

  { TWebbedAbility (instance size 44, VMT 557B5E7C):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type,
    $28 duration mode. }
  TWebbedAbility = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetDefense(A1: TAbilityOwner): Shortint; override;
    function GetTotalDuration: Integer; override;
  end;

  { TStunnedAbility (instance size 44, VMT 557B600C):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type, $28 duration mode. }
  TStunnedAbility = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetDefense(A1: TAbilityOwner): Shortint; override;
    function GetTotalDuration: Integer; override;
  end;

  { TBurningAbility (instance size 44, VMT 557B619C):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type, $28 duration mode. }
  TBurningAbility = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure NewCombatTurn(A1: TCombatObject; A2: Shortint); override;
    function GetTotalDuration: Integer; override;
  end;

  { TVertigoAbility (instance size 44, VMT 557B632C):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type, $28 duration mode. }
  TVertigoAbility = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetAttack(A1: TAbilityOwner): Shortint; override;
    function GetDefense(A1: TAbilityOwner): Shortint; override;
    function GetTotalDuration: Integer; override;
  end;

  { TCursedAbility (instance size 44, VMT 557B64BC):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type, $28 duration mode. }
  TCursedAbility = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetDefense(A1: TAbilityOwner): Shortint; override;
    function GetResistance(A1: TAbilityOwner): Shortint; override;
    function GetSourceName(A1: TAbilityOwner): string; override;
    function GetTotalDuration: Integer; override;
  end;

  { THolyFear (instance size 44, VMT 557B664C):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type, $28 duration mode. }
  THolyFear = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetSourceName(A1: TAbilityOwner): string; override;
    function GetTotalDuration: Integer; override;
  end;

  { TPanickedAbility (instance size 44, VMT 557B67D4):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type, $28 duration mode. }
  TPanickedAbility = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function Expand(A1: TAbilityOwner): Boolean; override;
  end;

  { TWallClimbingAbility (instance size 40, VMT 557B6968):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type. }
  TWallClimbingAbility = class(TAdjustableAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetWallCombatFeatures(A1: TAbilityOwner): TWallCombatFeatures; override;
  end;

  { TPassWallAbility (instance size 40, VMT 557B6AFC):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type. }
  TPassWallAbility = class(TAdjustableAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetWallCombatFeatures(A1: TAbilityOwner): TWallCombatFeatures; override;
  end;

  { TResurrectedAbility (instance size 40, VMT 557B6C88):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type. }
  TResurrectedAbility = class(TAdjustableAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TAnimatedAbility (instance size 40, VMT 557B6E18):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type. }
  TAnimatedAbility = class(TAdjustableAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TCombatResurrectedAbility (instance size 40, VMT 557B6FA4):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type. }
  TCombatResurrectedAbility = class(TAdjustableAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TMarksmanshipAbility (instance size 48; $28 maximum level, $2C level costs; VMT 557B7144) }
  TMarksmanshipAbility = class(TMultiLevelAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetLevelName(A1: Integer): string; override;
  end;

  { TMovementAbility (instance size 44; $28 FMoveTypes; VMT 557B72DC) }
  TMovementAbility = class(TAdjustableAbility)
  public
    FMoveTypes: TMoveTypes; { $28 }
    F_MovementAbility_29: array[0..2] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetMoveTypes(A1: TAbilityOwner): TMoveTypes; override;
    function GetWallCombatFeatures(A1: TAbilityOwner): TWallCombatFeatures; override;
  end;

  { TImmunityAbility (instance size 44; $28 FImmunityTypes; VMT 557B7468) }
  TImmunityAbility = class(TEnhancementAbility)
  public
    FImmunityTypes: TDamageTypes; { $28 }
    F_ImmunityAbility_2A: array[0..1] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetMoveTypes(A1: TAbilityOwner): TMoveTypes; override;
    function GetImmunityTypes(A1: TAbilityOwner): TDamageTypes; override;
  end;

  { TProtectionAbility (instance size 44; $28 FProtectionTypes; VMT 557B75F4) }
  TProtectionAbility = class(TEnhancementAbility)
  public
    FProtectionTypes: TDamageTypes; { $28 }
    F_ProtectionAbility_2A: array[0..1] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetProtectionTypes(A1: TAbilityOwner): TDamageTypes; override;
  end;

  { TEntangledAbility (instance size 40, VMT 557B7784):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type. }
  TEntangledAbility = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetDefense(A1: TAbilityOwner): Shortint; override;
    function GetDurationMode: TDurationMode; override;
    function GetTotalDuration: Shortint; override;
    function CreateEnchantment: TUnitEnchantment; override;
  end;

  { TFrozenAbility (instance size 40, VMT 557B7928):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type. }
  TFrozenAbility = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetDefense(A1: TAbilityOwner): Shortint; override;
    function GetDurationMode: TDurationMode; override;
    function GetTotalDuration: Shortint; override;
    function CreateEnchantment: TUnitEnchantment; override;
  end;

  { TTurnedUndeadAbility (instance size 40, VMT 557B7AC4):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type. }
  TTurnedUndeadAbility = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetDurationMode: TDurationMode; override;
    function GetTotalDuration: Shortint; override;
    function CreateEnchantment: TUnitEnchantment; override;
  end;

  { THasteAbility (instance size 40, VMT 557B7C6C):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type. }
  THasteAbility = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TStoneSkinAbility (instance size 40, VMT 557B7E08):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type. }
  TStoneSkinAbility = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetDefense(A1: TAbilityOwner): Shortint; override;
    function GetSourceName(A1: TAbilityOwner): string; override;
  end;

  { TEnchantedWeaponAbility (instance size 40, VMT 557B7FAC):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type. }
  TEnchantedWeaponAbility = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetAttack(A1: TAbilityOwner): Shortint; override;
    function GetDamage(A1: TAbilityOwner): Shortint; override;
    function GetAIUpkeepPriority(A1: TAbilityOwner): Integer; override;
  end;

  { TSummonedAbility (instance size 40, VMT 557B8158):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type. }
  TSummonedAbility = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function Remove(A1: TAbilityOwner): Boolean; override;
    function GetAIUpkeepPriority(A1: TAbilityOwner): Integer; override;
    function GetDefaultManaUpkeep(AUnit: TAbstractUnit): Integer;
    function GetDefaultDispelResistance(AUnit: TAbstractUnit): Integer;
    function UnitIndexToAIUpkeepPriority(A1: Integer): Integer;
  end;

  { TFuryAbility (instance size 40, VMT 557B82F8):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type. }
  TFuryAbility = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetAttack(A1: TAbilityOwner): Shortint; override;
    function GetDefense(A1: TAbilityOwner): Shortint; override;
    function GetAIUpkeepPriority(A1: TAbilityOwner): Integer; override;
  end;

  { TFreeMovementAbility (instance size 40, VMT 557B8490):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type. }
  TFreeMovementAbility = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { THolyChampionEnchantment (instance size 40, VMT 557B8638):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type. }
  THolyChampionEnchantment = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TUnholyChampionEnchantment (instance size 40, VMT 557B87E8):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type. }
  TUnholyChampionEnchantment = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TConcealmentEnchantment (instance size 40; $08 name, $0C ID, $20 selection types, $24 ability type; VMT 557B899C) }
  TConcealmentEnchantment = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TFireAuraEnchantment (instance size 40; $08 name, $0C ID, $20 selection types, $24 ability type; VMT 557B8B48) }
  TFireAuraEnchantment = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function Remove(A1: TAbilityOwner): Boolean; override;
  end;

  { TWaterWalkingEnchantment (instance size 40; $08 name, $0C ID, $20 selection types, $24 ability type; VMT 557B8CF0) }
  TWaterWalkingEnchantment = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function Remove(A1: TAbilityOwner): Boolean; override;
  end;

  { TWindWalkingEnchantment (instance size 40; $08 name, $0C ID, $20 selection types, $24 ability type; VMT 557B8EA0) }
  TWindWalkingEnchantment = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function Remove(A1: TAbilityOwner): Boolean; override;
  end;

  { TLiquidFormEnchantment (instance size 40; $08 name, $0C ID, $20 selection types, $24 ability type; VMT 557B904C) }
  TLiquidFormEnchantment = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function Remove(A1: TAbilityOwner): Boolean; override;
    function GetAIUpkeepPriority(A1: TAbilityOwner): Integer; override;
  end;

  { TBlessedEnchantment (instance size 40, VMT 557B91F8):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type. }
  TBlessedEnchantment = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetDefense(A1: TAbilityOwner): Shortint; override;
    function GetResistance(A1: TAbilityOwner): Shortint; override;
    function GetSourceName(A1: TAbilityOwner): string; override;
    function GetAIUpkeepPriority(A1: TAbilityOwner): Integer; override;
  end;

  { TDarkGiftEnchantment (instance size 40; $08 name, $0C ID, $20 selection types, $24 ability type; VMT 557B939C) }
  TDarkGiftEnchantment = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetDamage(A1: TAbilityOwner): Shortint; override;
    function GetAIUpkeepPriority(A1: TAbilityOwner): Integer; override;
  end;

  { TFireProtectionEnchantment (instance size 40, VMT 557B9544):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type. }
  TFireProtectionEnchantment = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetSourceName(A1: TAbilityOwner): string; override;
  end;

  { TSlowEnchantmentAbility (instance size 40, VMT 557B96F8):
    inherited $08 name, $0C ability ID, $20 selection types, $24 ability type. }
  TSlowEnchantmentAbility = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CombatDone(A1: TCombatObject); override;
    function CreateEnchantment: TUnitEnchantment; override;
  end;

procedure RegisterPassiveAbilities(Control: TAbilityControl);
procedure UnregisterPassiveAbilities(Control: TAbilityControl);

implementation

constructor TVisionAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSelectionTypes := [astUnit, astHeadItem, astTorsoItem, astDefenseItem, astRingItem, astEditor];
  FMaxLevel := 4;
  FAbilityID := 64;
  FLevelCosts[1] := 5;
  FLevelCosts[2] := 5;
  FLevelCosts[3] := 5;
  FLevelCosts[4] := 5;
end;

function TVisionAbility.GetLevelName(A1: Integer): string;
begin
  case A1 of
    0: Result := TranslateRStr(VisionRStr);
    1: Result := TranslateRStr(VisionRStr) + ' I';
    2: Result := TranslateRStr(VisionRStr) + ' II';
    3: Result := TranslateRStr(VisionRStr) + ' III';
    4: Result := TranslateRStr(VisionRStr) + ' IV';
  end;
end;

constructor THolyChampionAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(HolyChampionRStr);
  FAbilityID := 146;
  FSelectionTypes := [astUnit, astHeadItem, astTorsoItem, astDefenseItem, astRingItem, astEditor];
end;

function THolyChampionAbility.CanExpand(A1: TAbilityOwner): Boolean;
begin
  Result := inherited CanExpand(A1);
  if Result and (A1 is TAbstractUnit) then
    Result := TAbstractUnit(A1).GetAlignment in alsPureGood;
end;

constructor TUnholyChampionAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(UnholyChampionRStr);
  FAbilityID := 147;
  FSelectionTypes := [astUnit, astHeadItem, astTorsoItem, astDefenseItem, astRingItem, astEditor];
end;

function TUnholyChampionAbility.CanExpand(A1: TAbilityOwner): Boolean;
begin
  Result := inherited CanExpand(A1);
  if Result and (A1 is TAbstractUnit) then
    Result := TAbstractUnit(A1).GetAlignment in alsPureEvil;
end;

constructor TNaturesBlessingAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(NaturesBlessingRStr);
  FAbilityID := 99;
  FAbilityType := atEnchantment;
  FSelectionTypes := [];
  FDurationMode := dmDay;
end;

function TNaturesBlessingAbility.GetAttack(A1: TAbilityOwner): Shortint;
begin
  Result := 1;
end;

function TNaturesBlessingAbility.GetDefense(A1: TAbilityOwner): Shortint;
begin
  Result := 1;
end;

function TNaturesBlessingAbility.GetResistance(A1: TAbilityOwner): Shortint;
begin
  Result := 1;
end;

function TNaturesBlessingAbility.Expand(A1: TAbilityOwner): Boolean;
begin
  Result := inherited Expand(A1);
  if A1 is TAbstractUnit then
    with TAbstractUnit(A1) do SetHitPoints(GetHits);
end;

constructor TBloodlustAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(BloodlustRStr);
  FAbilityID := 168;
  FAbilityType := atEnchantment;
  FSelectionTypes := [];
  FDurationMode := dmDay;
end;

function TBloodlustAbility.GetAttack(A1: TAbilityOwner): Shortint;
begin
  Result := 1;
end;

function TBloodlustAbility.GetDefense(A1: TAbilityOwner): Shortint;
begin
  Result := -1;
end;

function TBloodlustAbility.GetDamage(A1: TAbilityOwner): Shortint;
begin
  Result := 2;
end;

constructor TPoisonedAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(PoisonedRStr);
  FAbilityID := 96;
  FAbilityType := atHandicap;
  FDurationMode := dmDay;
  FSelectionTypes := [];
end;

function TPoisonedAbility.GetAttack(A1: TAbilityOwner): Shortint;
begin
  Result := -1;
end;

function TPoisonedAbility.GetDefense(A1: TAbilityOwner): Shortint;
begin
  Result := -1;
end;

function TPoisonedAbility.GetResistance(A1: TAbilityOwner): Shortint;
begin
  Result := -1;
end;

function TPoisonedAbility.GetDamage(A1: TAbilityOwner): Shortint;
begin
  Result := -1;
end;

constructor TSlowEnchantmentAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(SlowRStr);
  FAbilityID := 132;
  FSelectionTypes := [];
end;

function TSlowEnchantmentAbility.CreateEnchantment: TUnitEnchantment;
begin
  Result := inherited CreateEnchantment;
  Result.FDispelResistance := 3;
end;

procedure TSlowEnchantmentAbility.CombatDone(A1: TCombatObject);
begin
  A1.GetAbilityOwner.RemoveAbility(FAbilityID);
end;

constructor TEntangledAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(EntangledRStr);
  FAbilityID := 94;
  FSelectionTypes := [];
end;

function TEntangledAbility.GetDurationMode: TDurationMode;
begin
  Result := dmCombatTurn;
end;

function TEntangledAbility.GetTotalDuration: Shortint;
begin
  Result := 3;
end;

function TEntangledAbility.GetDefense(A1: TAbilityOwner): Shortint;
begin
  Result := -2;
end;

function TEntangledAbility.CreateEnchantment: TUnitEnchantment;
begin
  Result := inherited CreateEnchantment;
  Result.FDispelResistance := 3;
end;

constructor TFrozenAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(FrozenRStr);
  FAbilityID := 95;
  FAbilityType := atEnchantment;
  FSelectionTypes := [];
end;

function TFrozenAbility.GetDurationMode: TDurationMode;
begin
  Result := dmCombatTurn;
end;

function TFrozenAbility.GetTotalDuration: Shortint;
begin
  Result := 2;
end;

function TFrozenAbility.CreateEnchantment: TUnitEnchantment;
begin
  Result := inherited CreateEnchantment;
  Result.FDispelResistance := 3;
end;

function TFrozenAbility.GetDefense(A1: TAbilityOwner): Shortint;
begin
  Result := -2;
end;

constructor TTurnedUndeadAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(TurnedUndeadRStr);
  FAbilityID := 34;
  FSelectionTypes := [];
end;

function TTurnedUndeadAbility.CreateEnchantment: TUnitEnchantment;
begin
  Result := inherited CreateEnchantment;
  Result.FDispelResistance := 4;
end;

function TTurnedUndeadAbility.GetDurationMode: TDurationMode;
begin
  Result := dmCombatTurn;
end;

function TTurnedUndeadAbility.GetTotalDuration: Shortint;
begin
  Result := 3;
end;

constructor TCrusaderAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(CrusaderRStr);
  FAbilityID := 101;
  FAbilityType := atHandicap;
  FDurationMode := dmDay;
  FSelectionTypes := [];
end;

function TCrusaderAbility.Remove(A1: TAbilityOwner): Boolean;
begin
  Result := inherited Remove(A1);
  TAbstractUnit(A1).Killed;
end;

function TCrusaderAbility.GetTotalDuration: Integer;
begin
  Result := 3;
end;

procedure TCrusaderAbility.NewTurn(A1: TAbilityOwner; A2: Shortint);
var
  Data: TDurationAbilityData;
begin
  if FDurationMode = dmDay then
  begin
    Data := TDurationAbilityData(A1.GetAbilityData(FAbilityID));
    if (Data <> nil) and (Data.FDuration <> 0) and (Data.FPlayerIndex = A2) then
      Dec(Data.FDuration);
  end;
end;

constructor TWebbedAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(WebbedRStr);
  FAbilityID := 97;
  FAbilityType := atHandicap;
  FDurationMode := dmCombatTurn;
  FSelectionTypes := [];
end;

function TWebbedAbility.GetTotalDuration: Integer;
begin
  Result := 3;
end;

function TWebbedAbility.GetDefense(A1: TAbilityOwner): Shortint;
begin
  Result := -2;
end;

constructor TBurningAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(BurningRStr);
  FAbilityID := 127;
  FAbilityType := atHandicap;
  FDurationMode := dmCombatTurn;
  FSelectionTypes := [];
end;


function TBurningAbility.GetTotalDuration: Integer;
begin
  Result := 3;
end;


procedure TBurningAbility.NewCombatTurn(A1: TCombatObject; A2: Shortint);
var
  Data: TDurationAbilityData;
begin
  Data := TDurationAbilityData(A1.GetAbilityOwner.GetAbilityData(FAbilityID));
  if Data <> nil then
  begin
    if (Data.FDuration <> 0) and (Data.FPlayerIndex = A2) then
    begin
      Dec(Data.FDuration);
      if Data.FDuration = 0 then A1.GetAbilityOwner.RemoveAbility(FAbilityID);
      if A1.GetAbilityOwner is TAbstractUnit then
        with TAbstractUnit(A1.GetAbilityOwner) do
          if HitRole(4 - GetResistance) then A1.ExecuteDamage(1);
    end;
  end
  else A1.GetAbilityOwner.RemoveAbility(FAbilityID);
end;


constructor TStunnedAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(StunnedRStr);
  FAbilityID := 92;
  FAbilityType := atHandicap;
  FDurationMode := dmCombatTurn;
  FSelectionTypes := [];
end;


function TStunnedAbility.GetTotalDuration: Integer;
begin
  Result := 1;
end;


function TStunnedAbility.GetDefense(A1: TAbilityOwner): Shortint;
begin
  Result := -2;
end;


constructor THolyFear.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(HolyFearRStr);
  FAbilityID := 53;
  FAbilityType := atHandicap;
  FSelectionTypes := [];
  FDurationMode := dmDay;
end;


function THolyFear.GetTotalDuration: Integer;
begin
  Result := 3;
end;


function THolyFear.GetSourceName(A1: TAbilityOwner): string;
begin
  { Original assumes the ability data exists. }
  with TDurationAbilityData(A1.GetAbilityData(FAbilityID)) do
    if FSource = 1 then
      Result := TranslateRStr(LifeMasteryRStr)
    else
      Result := inherited GetSourceName(A1);
end;


constructor TDecayAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(DecayRStr);
  FAbilityID := 131;
  FAbilityType := atHandicap;
  FDurationMode := dmEntireCombat;
  FSelectionTypes := [];
end;


procedure TDecayAbility.NewCombatTurn(A1: TCombatObject; A2: Shortint); { Tried player address-taking, data copy/with and comparison widths; still differs. }
var
  Data: TDurationAbilityData;
begin
  with A1 do
  begin
    Data := TDurationAbilityData(GetAbilityOwner.GetAbilityData(FAbilityID));
    if (Data <> nil) and (Data.FPlayerIndex = A2) then
      if GetAbilityOwner is TAbstractUnit then ExecuteDamage(1);
  end;
end;


procedure TDecayAbility.CombatDone(A1: TCombatObject);
begin
  A1.DestroyObject;
end;


constructor TPanickedAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(PanickedRStr);
  FAbilityID := 108;
  FAbilityType := atHandicap;
  FDurationMode := dmEntireCombat;
  FSelectionTypes := [];
end;


function TPanickedAbility.Expand(A1: TAbilityOwner): Boolean;
begin
  Result := inherited Expand(A1);
  if A1 is TAbstractUnit then TAbstractUnit(A1).Changed;
end;


constructor TResurrectedAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(ResurrectedRStr);
  FAbilityID := 128;
  FAbilityType := atHandicap;
  FSelectionTypes := [];
end;


constructor TAnimatedAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(AnimatedRStr);
  FAbilityID := 129;
  FAbilityType := atHandicap;
  FSelectionTypes := [];
end;


constructor TCombatResurrectedAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(ResurrectedRStr);
  FAbilityID := 130;
  FAbilityType := atHandicap;
  FSelectionTypes := [];
end;


constructor TWallClimbingAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(WallClimbingRStr);
  FAbilityID := 36;
  FSelectionTypes := [astUnit, astHeadItem, astTorsoItem, astDefenseItem, astRingItem, astEditor];
end;


function TWallClimbingAbility.GetWallCombatFeatures(A1: TAbilityOwner): TWallCombatFeatures;
begin
  Result := [wcWallPassing, wcParticipate];
end;


constructor TPassWallAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(PassWallRStr);
  FAbilityID := 66;
  FSelectionTypes := [astUnit, astHeadItem, astTorsoItem, astDefenseItem, astRingItem];
end;


function TPassWallAbility.GetWallCombatFeatures(A1: TAbilityOwner): TWallCombatFeatures;
begin
  Result := [wcWallPassing, wcParticipate];
end;


constructor TVertigoAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(VertigoRStr);
  FAbilityID := 98;
  FAbilityType := atHandicap;
  FDurationMode := dmDay;
  FSelectionTypes := [];
end;


function TVertigoAbility.GetTotalDuration: Integer;
begin
  Result := 3;
end;


function TVertigoAbility.GetAttack(A1: TAbilityOwner): Shortint;
begin
  Result := -2;
end;


function TVertigoAbility.GetDefense(A1: TAbilityOwner): Shortint;
begin
  Result := -2;
end;


constructor TCursedAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(CursedRStr);
  FAbilityID := 93;
  FSelectionTypes := [];
  FDurationMode := dmDay;
end;


function TCursedAbility.GetSourceName(A1: TAbilityOwner): string;
var
  Data: TDurationAbilityData;
begin
  Data := TDurationAbilityData(A1.GetAbilityData(FAbilityID));
  if (Data <> nil) and (Data.FSource = 1) then
    Result := TranslateRStr(DeathMasteryRStr)
  else
    Result := inherited GetSourceName(A1);
end;


function TCursedAbility.GetTotalDuration: Integer;
begin
  Result := 3;
end;


function TCursedAbility.GetDefense(A1: TAbilityOwner): Shortint;
begin
  Result := -2;
end;


function TCursedAbility.GetResistance(A1: TAbilityOwner): Shortint;
begin
  Result := -2;
end;


constructor THasteAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(HasteRStr);
  FAbilityID := 152;
end;


constructor TStoneSkinAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(StoneSkinRStr);
  FAbilityID := 153;
end;


function TStoneSkinAbility.GetSourceName(A1: TAbilityOwner): string;
begin
  { Original assumes the ability data and enchantment exist. }
  with TUnitEnchantmentAbilityData(A1.GetAbilityData(FAbilityID)) do
    if FEnchantment.FSource = -2 then
      Result := TranslateRStr(EarthMasteryRStr)
    else
      Result := inherited GetSourceName(A1);
end;


function TStoneSkinAbility.GetDefense(A1: TAbilityOwner): Shortint;
begin
  Result := 2;
end;


constructor TFireProtectionEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(FireProtectionRStr);
  FAbilityID := 167;
end;


function TFireProtectionEnchantment.GetSourceName(A1: TAbilityOwner): string;
begin
  { Original assumes the ability data and enchantment exist. }
  with TUnitEnchantmentAbilityData(A1.GetAbilityData(FAbilityID)) do
    if FEnchantment.FSource = -2 then
      Result := TranslateRStr(FireMasteryRStr)
    else
      Result := inherited GetSourceName(A1);
end;


constructor TEnchantedWeaponAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(EnchantedWeaponRStr);
  FAbilityID := 154;
end;


function TEnchantedWeaponAbility.GetAttack(A1: TAbilityOwner): Shortint;
begin
  Result := 1;
end;


function TEnchantedWeaponAbility.GetDamage(A1: TAbilityOwner): Shortint;
begin
  Result := 1;
end;


function TEnchantedWeaponAbility.GetAIUpkeepPriority(A1: TAbilityOwner): Integer;
begin
  Result := TAbstractUnit(A1).GetUnitLevel + 225;
  if A1 is TLeader then Inc(Result, 50);
end;


constructor TSummonedAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(SummonedRStr);
  FAbilityID := 155;
end;


function TSummonedAbility.GetDefaultManaUpkeep(AUnit: TAbstractUnit): Integer;
begin
  if AUnit is TUnit then Result := (AUnit.GetUnitLevel + 1) * 2
  else Result := 0;
end;


function TSummonedAbility.GetDefaultDispelResistance(AUnit: TAbstractUnit): Integer;
begin
  if AUnit is TUnit then Result := AUnit.GetUnitLevel + 3
  else Result := 0;
end;


function TSummonedAbility.Remove(A1: TAbilityOwner): Boolean;
begin
  Result := inherited Remove(A1);
  if Result then
    with TAbstractUnit(A1) do
    begin
      Killed;
      SetOwner(nil);
    end;
end;


function TSummonedAbility.GetAIUpkeepPriority(A1: TAbilityOwner): Integer;
begin
  case TAbstractUnit(A1).GetUnitLevel of
    1: Result := 250;
    2: Result := 250;
    3: Result := 500;
    4: Result := 1000;
  else
    Result := 1000;
  end;
end;


function TSummonedAbility.UnitIndexToAIUpkeepPriority(A1: Integer): Integer;
begin
  case AoWHSSet.FUnitResources.GetUnitResource(A1).FLevel of
    1: Result := 250;
    2: Result := 250;
    3: Result := 500;
    4: Result := 1000;
  else
    Result := 1000;
  end;
end;


constructor TFuryAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(FuryRStr);
  FAbilityID := 156;
end;


function TFuryAbility.GetAttack(A1: TAbilityOwner): Shortint;
begin
  Result := 2;
end;


function TFuryAbility.GetDefense(A1: TAbilityOwner): Shortint;
begin
  Result := -1;
end;


function TFuryAbility.GetAIUpkeepPriority(A1: TAbilityOwner): Integer;
begin
  Result := TAbstractUnit(A1).GetUnitLevel + 200;
  if A1 is TLeader then Dec(Result, 50);
end;


constructor TFreeMovementAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(FreeMovementRStr);
  FAbilityID := 157;
end;


constructor THolyChampionEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(HolyChampionRStr);
  FAbilityID := 160;
end;


constructor TUnholyChampionEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(UnholyChampionRStr);
  FAbilityID := 161;
end;


constructor TBlessedEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(BlessedRStr);
  FAbilityID := 158;
end;


function TBlessedEnchantment.GetDefense(A1: TAbilityOwner): Shortint;
begin
  Result := 1;
end;


function TBlessedEnchantment.GetResistance(A1: TAbilityOwner): Shortint;
begin
  Result := 1;
end;


function TBlessedEnchantment.GetSourceName(A1: TAbilityOwner): string;
begin
  { Original assumes the ability data and enchantment exist. }
  with TUnitEnchantmentAbilityData(A1.GetAbilityData(FAbilityID)) do
    if FEnchantment.FSource = -2 then
      Result := TranslateRStr(LifeMasteryRStr)
    else
      Result := inherited GetSourceName(A1);
end;


function TBlessedEnchantment.GetAIUpkeepPriority(A1: TAbilityOwner): Integer;
begin
  Result := TAbstractUnit(A1).GetUnitLevel + 200;
  if A1 is TLeader then Inc(Result, 50);
end;


constructor TDarkGiftEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(DarkGiftRStr);
  FAbilityID := 169;
end;

function TDarkGiftEnchantment.GetDamage(A1: TAbilityOwner): Shortint;
begin
  Result := 1;
end;

function TDarkGiftEnchantment.GetAIUpkeepPriority(A1: TAbilityOwner): Integer;
begin
  Result := TAbstractUnit(A1).GetUnitLevel + 200;
  if A1 is TLeader then Inc(Result, 50);
end;

constructor THighPrayerBlessingAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(HighPrayerBlessingRStr);
  FAbilityID := 100;
  FAbilityType := atEnhancement;
  FDurationMode := dmEntireCombat;
  FSelectionTypes := [];
end;

function THighPrayerBlessingAbility.GetDefense(A1: TAbilityOwner): Shortint;
begin
  Result := 1;
end;

function THighPrayerBlessingAbility.GetResistance(A1: TAbilityOwner): Shortint;
begin
  Result := 1;
end;

constructor TConcealmentEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(ConcealmentRStr);
  FAbilityID := 162;
end;

constructor TFireAuraEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(FireAuraRStr);
  FAbilityID := 163;
end;

function TFireAuraEnchantment.Remove(A1: TAbilityOwner): Boolean;
var
  X, Y, L: Shortint;
begin
  Result := inherited Remove(A1);
  if Result and (A1.Owner is TArmy) then
  begin
    TAbstractUnit(A1).GetLocation(X, Y, L);
    if X <> -1 then
      with AoWHSMap.MapContainer.GetField(X, Y, L) do
        TArmy(A1.Owner).ValidateTerrain(TerrainType, OverlayType);
  end;
end;

constructor TWaterWalkingEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(WaterWalkingRStr);
  FAbilityID := 164;
end;

function TWaterWalkingEnchantment.Remove(A1: TAbilityOwner): Boolean;
var
  X, Y, L: Shortint;
begin
  Result := inherited Remove(A1);
  if Result and (A1.Owner is TArmy) then
  begin
    TAbstractUnit(A1).GetLocation(X, Y, L);
    if X <> -1 then
      with AoWHSMap.MapContainer.GetField(X, Y, L) do
        TArmy(A1.Owner).ValidateTerrain(TerrainType, OverlayType);
  end;
end;

constructor TWindWalkingEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(WindWalkingRStr);
  FAbilityID := 165;
end;

function TWindWalkingEnchantment.Remove(A1: TAbilityOwner): Boolean;
var
  X, Y, L: Shortint;
begin
  Result := inherited Remove(A1);
  if Result and (A1.Owner is TArmy) then
  begin
    TAbstractUnit(A1).GetLocation(X, Y, L);
    if X <> -1 then
      with AoWHSMap.MapContainer.GetField(X, Y, L) do
        TArmy(A1.Owner).ValidateTerrain(TerrainType, OverlayType);
  end;
end;

constructor TLiquidFormEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(LiquidFormRStr);
  FAbilityID := 166;
end;

function TLiquidFormEnchantment.Remove(A1: TAbilityOwner): Boolean;
var
  X, Y, L: Shortint;
begin
  Result := inherited Remove(A1);
  if Result and (A1.Owner is TArmy) then
  begin
    TAbstractUnit(A1).GetLocation(X, Y, L);
    if X <> -1 then
      with AoWHSMap.MapContainer.GetField(X, Y, L) do
        TArmy(A1.Owner).ValidateTerrain(TerrainType, OverlayType);
  end;
end;

function TLiquidFormEnchantment.GetAIUpkeepPriority(A1: TAbilityOwner): Integer;
begin
  Result := TAbstractUnit(A1).GetUnitLevel + 300;
  if A1 is TLeader then Inc(Result, 50);
end;

constructor TMarksmanshipAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilityName := TranslateRStr(MarksmanshipRStr);
  FAbilityType := atEnhancement;
  FAbilityID := 32;
  FSelectionTypes := [astUnit, astHeadItem, astTorsoItem, astDefenseItem, astRingItem, astEditor];
  FMaxLevel := 4;
  FLevelCosts[1] := 5;
  FLevelCosts[2] := 5;
  FLevelCosts[3] := 5;
  FLevelCosts[4] := 5;
end;

function TMarksmanshipAbility.GetLevelName(A1: Integer): string;
begin
  case A1 of
    0: Result := TranslateRStr(MarksmanshipRStr);
    1: Result := TranslateRStr(MarksmanshipRStr) + ' I';
    2: Result := TranslateRStr(MarksmanshipRStr) + ' II';
    3: Result := TranslateRStr(MarksmanshipRStr) + ' III';
    4: Result := TranslateRStr(MarksmanshipRStr) + ' IV';
  end;
end;

constructor TMovementAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSelectionTypes := [astUnit, astRingItem];
  FAbilityType := atMovement;
  FSkillPointCost := 0;
end;

function TMovementAbility.GetMoveTypes(A1: TAbilityOwner): TMoveTypes;
begin
  Result := FMoveTypes;
end;

function TMovementAbility.GetWallCombatFeatures(A1: TAbilityOwner): TWallCombatFeatures;
begin
  if FAbilityID = 1 then Result := [wcWallPassing, wcParticipate]
  else Result := [];
end;

constructor TImmunityAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSelectionTypes := [astUnit, astDefenseItem, astRingItem];
  FAbilityType := atEnhancement;
end;

function TImmunityAbility.GetImmunityTypes(A1: TAbilityOwner): TDamageTypes;
begin
  Result := FImmunityTypes;
end;

function TImmunityAbility.GetMoveTypes(A1: TAbilityOwner): TMoveTypes;
begin
  if dtFire in FImmunityTypes then Result := [mtLavaCrossing]
  else Result := [];
end;

constructor TProtectionAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSelectionTypes := [astUnit, astDefenseItem, astRingItem, astEditor];
  FAbilityType := atEnhancement;
end;

function TProtectionAbility.GetProtectionTypes(A1: TAbilityOwner): TDamageTypes;
begin
  Result := FProtectionTypes;
end;

function CreateMovementAbility(ID: Integer; const Name: string; MoveTypes: TMoveTypes): TMovementAbility;
var
  Ability: TMovementAbility;
begin
  Ability := TMovementAbility.Create(nil);
  Ability.FAbilityID := ID;
  Ability.FAbilityName := Name;
  Ability.FMoveTypes := MoveTypes;
  if (mtMountaineering in MoveTypes) or (mtForestry in MoveTypes) or
    (mtCaveCrawling in MoveTypes) then
    Ability.FSelectionTypes := Ability.FSelectionTypes + [astEditor];
  Result := Ability;
end;

function CreateImmunityAbility(ID: Integer; const Name: string; DamageTypes: TDamageTypes): TImmunityAbility;
var
  Ability: TImmunityAbility;
begin
  Ability := TImmunityAbility.Create(nil);
  Ability.FAbilityID := ID;
  Ability.FAbilityName := Name;
  Ability.FImmunityTypes := DamageTypes;
  if [dtPhysical, dtDeath, dtHoly, dtMagic] * DamageTypes = [] then
    Ability.FSelectionTypes := [astUnit, astRingItem]
  else if [dtDeath, dtHoly, dtMagic] * DamageTypes = [] then
    Ability.FSelectionTypes := [astUnit, astRingItem]
  else
    Ability.FSelectionTypes := [astUnit];
  if [dtPhysical, dtMagic] * DamageTypes = [] then
    Ability.FSelectionTypes := Ability.FSelectionTypes + [astTorsoItem];
  Result := Ability;
end;

function CreateProtectionAbility(ID: Integer; const Name: string; DamageTypes: TDamageTypes;
  SelectionTypes: TAbilitySelectionTypes): TProtectionAbility;
var
  Ability: TProtectionAbility;
begin
  Ability := TProtectionAbility.Create(nil);
  Ability.FAbilityID := ID;
  Ability.FAbilityName := Name;
  Ability.FProtectionTypes := DamageTypes;
  Ability.FSelectionTypes := SelectionTypes;
  Result := Ability;
end;

procedure RegisterPassiveAbilities(Control: TAbilityControl);
begin
  Control.RegisterAbility(CreateImmunityAbility(7, TranslateRStr(FireImmunityRStr), [dtFire]));
  Control.RegisterAbility(CreateImmunityAbility(8, TranslateRStr(ColdImmunityRStr), [dtCold]));
  Control.RegisterAbility(CreateImmunityAbility(9, TranslateRStr(LightningImmunityRStr), [dtLightning]));
  Control.RegisterAbility(CreateImmunityAbility(10, TranslateRStr(PoisonImmunityRStr), [dtPoison]));
  Control.RegisterAbility(CreateImmunityAbility(11, TranslateRStr(DeathImmunityRStr), [dtDeath]));
  Control.RegisterAbility(CreateImmunityAbility(12, TranslateRStr(HolyImmunityRStr), [dtHoly]));
  Control.RegisterAbility(CreateImmunityAbility(13, TranslateRStr(PhysicalImmunityRStr), [dtPhysical]));
  Control.RegisterAbility(CreateImmunityAbility(6, TranslateRStr(MagicImmunityRStr), [dtMagic]));
  Control.RegisterAbility(CreateProtectionAbility(71, TranslateRStr(FireProtectionRStr), [dtFire], [astUnit, astDefenseItem, astRingItem]));
  Control.RegisterAbility(CreateProtectionAbility(76, TranslateRStr(ColdProtectionRStr), [dtCold], [astUnit, astDefenseItem, astRingItem]));
  Control.RegisterAbility(CreateProtectionAbility(74, TranslateRStr(LightningProtectionRStr), [dtLightning], [astUnit, astDefenseItem, astRingItem]));
  Control.RegisterAbility(CreateProtectionAbility(73, TranslateRStr(PoisonProtectionRStr), [dtPoison], [astUnit, astDefenseItem, astRingItem]));
  Control.RegisterAbility(CreateProtectionAbility(70, TranslateRStr(DeathProtectionRStr), [dtDeath], [astUnit, astDefenseItem, astRingItem]));
  Control.RegisterAbility(CreateProtectionAbility(72, TranslateRStr(HolyProtectionRStr), [dtHoly], [astUnit, astDefenseItem, astRingItem]));
  Control.RegisterAbility(CreateProtectionAbility(77, TranslateRStr(PhysicalProtectionRStr), [dtPhysical], [astUnit, astDefenseItem, astRingItem]));
  Control.RegisterAbility(CreateProtectionAbility(75, TranslateRStr(MagicProtectionRStr), [dtMagic], [astUnit, astDefenseItem, astRingItem]));
  Control.RegisterAbility(CreateMovementAbility(0, TranslateRStr(WalkingRStr), [mtWalking]));
  Control.RegisterAbility(CreateMovementAbility(1, TranslateRStr(FlyingRStr), [mtFlying]));
  Control.RegisterAbility(CreateMovementAbility(2, TranslateRStr(SwimmingRStr), [mtSwimming]));
  Control.RegisterAbility(CreateMovementAbility(3, TranslateRStr(ForestryRStr), [mtForestry]));
  Control.RegisterAbility(CreateMovementAbility(4, TranslateRStr(CaveCrawlingRStr), [mtCaveCrawling]));
  Control.RegisterAbility(CreateMovementAbility(5, TranslateRStr(MountaineeringRStr), [mtMountaineering]));
  Control.RegisterAbility(CreateMovementAbility(23, TranslateRStr(SailingRStr), [mtSwimming]));
  Control.RegisterAbility(CreateMovementAbility(42, TranslateRStr(TunnelingRStr), [mtTunneling]));
  Control.RegisterAbility(CreateMovementAbility(59, TranslateRStr(FloatingRStr), [mtFlying]));
  Control.RegisterAbility(CreateEnhancementAbility(26, TranslateRStr(TrailOfDarknessRStr), [astUnit, astHeadItem, astTorsoItem, astDefenseItem, astRingItem]));
  Control.RegisterAbility(CreateEnhancementAbility(39, TranslateRStr(NightVisionRStr), [astUnit, astHeadItem, astTorsoItem, astDefenseItem, astRingItem]));
  Control.RegisterAbility(CreateEnhancementAbility(43, TranslateRStr(IgnitionRStr), [astUnit, astHeadItem, astTorsoItem, astDefenseItem, astRingItem]));
  Control.RegisterAbility(CreateEnhancementAbility(49, TranslateRStr(RegenerationRStr), [astUnit, astHeadItem, astTorsoItem, astDefenseItem, astRingItem]));
  Control.RegisterAbility(CreateEnhancementAbility(51, TranslateRStr(CauseFearRStr), [astUnit, astHeadItem, astTorsoItem, astDefenseItem, astRingItem]));
  Control.RegisterAbility(CreateEnhancementAbility(54, TranslateRStr(InvisibilityRStr), [astUnit, astHeadItem, astTorsoItem, astDefenseItem, astRingItem]));
  Control.RegisterAbility(CreateEnhancementAbility(63, TranslateRStr(DragonRStr), [astUnit]));
  Control.RegisterAbility(CreateEnhancementAbility(37, TranslateRStr(BardsSkillsRStr), [astUnit, astEditor]));
  Control.RegisterAbility(CreateEnhancementAbility(41, TranslateRStr(TrueVisionRStr), [astUnit, astHeadItem, astTorsoItem, astDefenseItem, astRingItem, astEditor]));
  Control.RegisterAbility(CreateEnhancementAbility(67, TranslateRStr(FearlessRStr), [astUnit, astHeadItem, astTorsoItem, astDefenseItem, astRingItem]));
  Control.RegisterAbility(CreateEnhancementAbility(68, TranslateRStr(PathOfDecayRStr), [astUnit, astHeadItem, astTorsoItem, astDefenseItem, astRingItem]));
  Control.RegisterAbility(CreateEnhancementAbility(69, TranslateRStr(PathOfLifeRStr), [astUnit, astHeadItem, astTorsoItem, astDefenseItem, astRingItem]));
  Control.RegisterAbility(CreateEnhancementAbility(109, TranslateRStr(PathOfFrostRStr), [astUnit, astHeadItem, astTorsoItem, astDefenseItem, astRingItem]));
  Control.RegisterAbility(TVisionAbility.Create(nil));
  Control.RegisterAbility(THolyChampionAbility.Create(nil));
  Control.RegisterAbility(TUnholyChampionAbility.Create(nil));
  Control.RegisterAbility(TWallClimbingAbility.Create(nil));
  Control.RegisterAbility(TPassWallAbility.Create(nil));
  Control.RegisterAbility(TCursedAbility.Create(nil));
  Control.RegisterAbility(TResurrectedAbility.Create(nil));
  Control.RegisterAbility(TAnimatedAbility.Create(nil));
  Control.RegisterAbility(TCombatResurrectedAbility.Create(nil));
  Control.RegisterAbility(TMarksmanshipAbility.Create(nil));
  Control.RegisterAbility(TSlowEnchantmentAbility.Create(nil));
  Control.RegisterAbility(TWebbedAbility.Create(nil));
  Control.RegisterAbility(TVertigoAbility.Create(nil));
  Control.RegisterAbility(TPoisonedAbility.Create(nil));
  Control.RegisterAbility(TEntangledAbility.Create(nil));
  Control.RegisterAbility(TFrozenAbility.Create(nil));
  Control.RegisterAbility(TStunnedAbility.Create(nil));
  Control.RegisterAbility(TNaturesBlessingAbility.Create(nil));
  Control.RegisterAbility(TBloodlustAbility.Create(nil));
  Control.RegisterAbility(TTurnedUndeadAbility.Create(nil));
  Control.RegisterAbility(THolyFear.Create(nil));
  Control.RegisterAbility(THasteAbility.Create(nil));
  Control.RegisterAbility(TStoneSkinAbility.Create(nil));
  Control.RegisterAbility(TEnchantedWeaponAbility.Create(nil));
  Control.RegisterAbility(TSummonedAbility.Create(nil));
  Control.RegisterAbility(TFuryAbility.Create(nil));
  Control.RegisterAbility(TFreeMovementAbility.Create(nil));
  Control.RegisterAbility(THolyChampionEnchantment.Create(nil));
  Control.RegisterAbility(TUnholyChampionEnchantment.Create(nil));
  Control.RegisterAbility(TConcealmentEnchantment.Create(nil));
  Control.RegisterAbility(TFireAuraEnchantment.Create(nil));
  Control.RegisterAbility(TWaterWalkingEnchantment.Create(nil));
  Control.RegisterAbility(TWindWalkingEnchantment.Create(nil));
  Control.RegisterAbility(TLiquidFormEnchantment.Create(nil));
  Control.RegisterAbility(TBlessedEnchantment.Create(nil));
  Control.RegisterAbility(TCosmeticSurgeryAbility.Create(nil));
  Control.RegisterAbility(TBurningAbility.Create(nil));
  Control.RegisterAbility(TFireProtectionEnchantment.Create(nil));
  Control.RegisterAbility(TPanickedAbility.Create(nil));
  Control.RegisterAbility(TDecayAbility.Create(nil));
  Control.RegisterAbility(THighPrayerBlessingAbility.Create(nil));
  Control.RegisterAbility(TDarkGiftEnchantment.Create(nil));
  Control.RegisterAbility(TCrusaderAbility.Create(nil));
  Control.RegisterAbility(CreateEnhancementAbility(138, TranslateRStr(SteppeConcealmentRStr), [astUnit, astHeadItem, astTorsoItem, astDefenseItem, astRingItem]));
  Control.RegisterAbility(CreateEnhancementAbility(139, TranslateRStr(UndergroundConcealmentRStr), [astUnit, astHeadItem, astTorsoItem, astDefenseItem, astRingItem]));
  Control.RegisterAbility(CreateEnhancementAbility(140, TranslateRStr(GrassConcealmentRStr), [astUnit, astHeadItem, astTorsoItem, astDefenseItem, astRingItem]));
  Control.RegisterAbility(CreateEnhancementAbility(141, TranslateRStr(SnowConcealmentRStr), [astUnit, astHeadItem, astTorsoItem, astDefenseItem, astRingItem]));
  Control.RegisterAbility(CreateEnhancementAbility(142, TranslateRStr(DesertConcealmentRStr), [astUnit, astHeadItem, astTorsoItem, astDefenseItem, astRingItem]));
  Control.RegisterAbility(CreateEnhancementAbility(143, TranslateRStr(WastelandConcealmentRStr), [astUnit, astHeadItem, astTorsoItem, astDefenseItem, astRingItem]));
  Control.RegisterAbility(CreateEnhancementAbility(144, TranslateRStr(WaterConcealmentRStr), [astUnit, astHeadItem, astTorsoItem, astDefenseItem, astRingItem]));
  Control.RegisterAbility(CreateEnhancementAbility(145, TranslateRStr(ConcealmentRStr), [astUnit, astHeadItem, astTorsoItem, astDefenseItem, astRingItem, astEditor]));
end;

procedure UnregisterPassiveAbilities(Control: TAbilityControl);
begin
  Control.UnregisterAbilityID(0);
  Control.UnregisterAbilityID(1);
  Control.UnregisterAbilityID(2);
  Control.UnregisterAbilityID(3);
  Control.UnregisterAbilityID(4);
  Control.UnregisterAbilityID(5);
  Control.UnregisterAbilityID(23);
  Control.UnregisterAbilityID(42);
  Control.UnregisterAbilityID(6);
  Control.UnregisterAbilityID(7);
  Control.UnregisterAbilityID(8);
  Control.UnregisterAbilityID(9);
  Control.UnregisterAbilityID(10);
  Control.UnregisterAbilityID(11);
  Control.UnregisterAbilityID(12);
  Control.UnregisterAbilityID(13);
  Control.UnregisterAbilityID(70);
  Control.UnregisterAbilityID(71);
  Control.UnregisterAbilityID(76);
  Control.UnregisterAbilityID(72);
  Control.UnregisterAbilityID(73);
  Control.UnregisterAbilityID(74);
  Control.UnregisterAbilityID(75);
  Control.UnregisterAbilityID(77);
  Control.UnregisterAbilityID(64);
  Control.UnregisterAbilityID(146);
  Control.UnregisterAbilityID(147);
  Control.UnregisterAbilityID(26);
  Control.UnregisterAbilityID(36);
  Control.UnregisterAbilityID(66);
  Control.UnregisterAbilityID(39);
  Control.UnregisterAbilityID(43);
  Control.UnregisterAbilityID(49);
  Control.UnregisterAbilityID(51);
  Control.UnregisterAbilityID(54);
  Control.UnregisterAbilityID(63);
  Control.UnregisterAbilityID(64);
  Control.UnregisterAbilityID(37);
  Control.UnregisterAbilityID(41);
  Control.UnregisterAbilityID(67);
  Control.UnregisterAbilityID(68);
  Control.UnregisterAbilityID(69);
  Control.UnregisterAbilityID(109);
  Control.UnregisterAbilityID(32);
  Control.UnregisterAbilityID(129);
  Control.UnregisterAbilityID(128);
  Control.UnregisterAbilityID(130);
  Control.UnregisterAbilityID(93);
  Control.UnregisterAbilityID(94);
  Control.UnregisterAbilityID(95);
  Control.UnregisterAbilityID(96);
  Control.UnregisterAbilityID(97);
  Control.UnregisterAbilityID(98);
  Control.UnregisterAbilityID(92);
  Control.UnregisterAbilityID(99);
  Control.UnregisterAbilityID(168);
  Control.UnregisterAbilityID(34);
  Control.UnregisterAbilityID(53);
  Control.UnregisterAbilityID(152);
  Control.UnregisterAbilityID(153);
  Control.UnregisterAbilityID(154);
  Control.UnregisterAbilityID(155);
  Control.UnregisterAbilityID(156);
  Control.UnregisterAbilityID(157);
  Control.UnregisterAbilityID(160);
  Control.UnregisterAbilityID(161);
  Control.UnregisterAbilityID(162);
  Control.UnregisterAbilityID(163);
  Control.UnregisterAbilityID(164);
  Control.UnregisterAbilityID(165);
  Control.UnregisterAbilityID(166);
  Control.UnregisterAbilityID(158);
  Control.UnregisterAbilityID(126);
  Control.UnregisterAbilityID(127);
  Control.UnregisterAbilityID(167);
  Control.UnregisterAbilityID(108);
  Control.UnregisterAbilityID(131);
  Control.UnregisterAbilityID(100);
  Control.UnregisterAbilityID(169);
  Control.UnregisterAbilityID(132);
  Control.UnregisterAbilityID(101);
  Control.UnregisterAbilityID(138);
  Control.UnregisterAbilityID(139);
  Control.UnregisterAbilityID(140);
  Control.UnregisterAbilityID(141);
  Control.UnregisterAbilityID(142);
  Control.UnregisterAbilityID(143);
  Control.UnregisterAbilityID(144);
  Control.UnregisterAbilityID(145);
end;


initialization
finalization

end.
