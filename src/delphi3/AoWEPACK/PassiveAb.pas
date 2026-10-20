unit PassiveAb;

{ Draft declarations of PassiveAb, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  The signature-order range TVisionAbility through TWebbedAbility is recovered;
  later classes remain drafts. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

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

  { THighPrayerBlessingAbility (instance size 44, VMT 557B5684) }
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

  { TDecayAbility (instance size 44, VMT 557B5CEC) }
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

  { TStunnedAbility (instance size 44, VMT 557B600C) }
  TStunnedAbility = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetDefense(A1: TAbilityOwner): Shortint; override;
    function GetTotalDuration: Integer; override;
  end;

  { TBurningAbility (instance size 44, VMT 557B619C) }
  TBurningAbility = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure NewCombatTurn(A1: TCombatObject; A2: Shortint); override;
    function GetTotalDuration: Integer; override;
  end;

  { TVertigoAbility (instance size 44, VMT 557B632C) }
  TVertigoAbility = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetAttack(A1: TAbilityOwner): Shortint; override;
    function GetDefense(A1: TAbilityOwner): Shortint; override;
    function GetTotalDuration: Integer; override;
  end;

  { TCursedAbility (instance size 44, VMT 557B64BC) }
  TCursedAbility = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetDefense(A1: TAbilityOwner): Shortint; override;
    function GetResistance(A1: TAbilityOwner): Shortint; override;
    function GetSourceName(A1: TAbilityOwner): string; override;
    function GetTotalDuration: Integer; override;
  end;

  { THolyFear (instance size 44, VMT 557B664C) }
  THolyFear = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetSourceName(A1: TAbilityOwner): string; override;
    function GetTotalDuration: Integer; override;
  end;

  { TPanickedAbility (instance size 44, VMT 557B67D4) }
  TPanickedAbility = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function Expand(A1: TAbilityOwner): Boolean; override;
  end;

  { TWallClimbingAbility (instance size 40, VMT 557B6968) }
  TWallClimbingAbility = class(TAdjustableAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetWallCombatFeatures(A1: TAbilityOwner): TWallCombatFeatures; override;
  end;

  { TPassWallAbility (instance size 40, VMT 557B6AFC) }
  TPassWallAbility = class(TAdjustableAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetWallCombatFeatures(A1: TAbilityOwner): TWallCombatFeatures; override;
  end;

  { TResurrectedAbility (instance size 40, VMT 557B6C88) }
  TResurrectedAbility = class(TAdjustableAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TAnimatedAbility (instance size 40, VMT 557B6E18) }
  TAnimatedAbility = class(TAdjustableAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TCombatResurrectedAbility (instance size 40, VMT 557B6FA4) }
  TCombatResurrectedAbility = class(TAdjustableAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TMarksmanshipAbility (instance size 48, VMT 557B7144) }
  TMarksmanshipAbility = class(TMultiLevelAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetLevelName(A1: Integer): string; override;
  end;

  { TMovementAbility (instance size 44, VMT 557B72DC) }
  TMovementAbility = class(TAdjustableAbility)
  public
    F_MovementAbility_28: Byte;
    F_MovementAbility_29: array[0..2] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetMoveTypes(A1: TAbilityOwner): TMoveTypes; override;
    function GetWallCombatFeatures(A1: TAbilityOwner): TWallCombatFeatures; override;
  end;

  { TImmunityAbility (instance size 44, VMT 557B7468) }
  TImmunityAbility = class(TEnhancementAbility)
  public
    F_ImmunityAbility_28: Word;
    F_ImmunityAbility_2A: array[0..1] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetMoveTypes(A1: TAbilityOwner): TMoveTypes; override;
    function GetImmunityTypes(A1: TAbilityOwner): TDamageTypes; override;
  end;

  { TProtectionAbility (instance size 44, VMT 557B75F4) }
  TProtectionAbility = class(TEnhancementAbility)
  public
    F_ProtectionAbility_28: Word;
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

  { THasteAbility (instance size 40, VMT 557B7C6C) }
  THasteAbility = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TStoneSkinAbility (instance size 40, VMT 557B7E08) }
  TStoneSkinAbility = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetDefense(A1: TAbilityOwner): Shortint; override;
    function GetSourceName(A1: TAbilityOwner): string; override;
  end;

  { TEnchantedWeaponAbility (instance size 40, VMT 557B7FAC) }
  TEnchantedWeaponAbility = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetAttack(A1: TAbilityOwner): Shortint; override;
    function GetDamage(A1: TAbilityOwner): Shortint; override;
    function GetAIUpkeepPriority(A1: TAbilityOwner): Integer; override;
  end;

  { TSummonedAbility (instance size 40, VMT 557B8158) }
  TSummonedAbility = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function Remove(A1: TAbilityOwner): Boolean; override;
    function GetAIUpkeepPriority(A1: TAbilityOwner): Integer; override;
    function GetDefaultManaUpkeep(AUnit: TAbstractUnit): Integer;
    function GetDefaultDispelResistance(AUnit: TAbstractUnit): Byte;
    procedure UnitIndexToAIUpkeepPriority(A1: Integer);  { draft }
  end;

  { TFuryAbility (instance size 40, VMT 557B82F8) }
  TFuryAbility = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetAttack(A1: TAbilityOwner): Shortint; override;
    function GetDefense(A1: TAbilityOwner): Shortint; override;
    function GetAIUpkeepPriority(A1: TAbilityOwner): Integer; override;
  end;

  { TFreeMovementAbility (instance size 40, VMT 557B8490) }
  TFreeMovementAbility = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { THolyChampionEnchantment (instance size 40, VMT 557B8638) }
  THolyChampionEnchantment = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TUnholyChampionEnchantment (instance size 40, VMT 557B87E8) }
  TUnholyChampionEnchantment = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TConcealmentEnchantment (instance size 40, VMT 557B899C) }
  TConcealmentEnchantment = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TFireAuraEnchantment (instance size 40, VMT 557B8B48) }
  TFireAuraEnchantment = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function Remove(A1: TAbilityOwner): Boolean; override;
  end;

  { TWaterWalkingEnchantment (instance size 40, VMT 557B8CF0) }
  TWaterWalkingEnchantment = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function Remove(A1: TAbilityOwner): Boolean; override;
  end;

  { TWindWalkingEnchantment (instance size 40, VMT 557B8EA0) }
  TWindWalkingEnchantment = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function Remove(A1: TAbilityOwner): Boolean; override;
  end;

  { TLiquidFormEnchantment (instance size 40, VMT 557B904C) }
  TLiquidFormEnchantment = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function Remove(A1: TAbilityOwner): Boolean; override;
    function GetAIUpkeepPriority(A1: TAbilityOwner): Integer; override;
  end;

  { TBlessedEnchantment (instance size 40, VMT 557B91F8) }
  TBlessedEnchantment = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetDefense(A1: TAbilityOwner): Shortint; override;
    function GetResistance(A1: TAbilityOwner): Shortint; override;
    function GetSourceName(A1: TAbilityOwner): string; override;
    function GetAIUpkeepPriority(A1: TAbilityOwner): Integer; override;
  end;

  { TDarkGiftEnchantment (instance size 40, VMT 557B939C) }
  TDarkGiftEnchantment = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetDamage(A1: TAbilityOwner): Shortint; override;
    function GetAIUpkeepPriority(A1: TAbilityOwner): Integer; override;
  end;

  { TFireProtectionEnchantment (instance size 40, VMT 557B9544) }
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

procedure RegisterPassiveAbilities(A1: Integer);  { draft }
procedure UnregisterPassiveAbilities(A1: Integer);  { draft }

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
begin end;

function TBurningAbility.GetTotalDuration: Integer;
begin Result := 0; end;

procedure TBurningAbility.NewCombatTurn(A1: TCombatObject; A2: Shortint);
begin end;

constructor TStunnedAbility.Create(AOwner: Engine.TECustomNode);
begin end;

function TStunnedAbility.GetTotalDuration: Integer;
begin Result := 0; end;

function TStunnedAbility.GetDefense(A1: TAbilityOwner): Shortint;
begin Result := 0; end;

constructor THolyFear.Create(AOwner: Engine.TECustomNode);
begin end;

function THolyFear.GetTotalDuration: Integer;
begin Result := 0; end;

function THolyFear.GetSourceName(A1: TAbilityOwner): string;
begin Result := ''; end;

constructor TDecayAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TDecayAbility.NewCombatTurn(A1: TCombatObject; A2: Shortint);
begin end;

procedure TDecayAbility.CombatDone(A1: TCombatObject);
begin end;

constructor TPanickedAbility.Create(AOwner: Engine.TECustomNode);
begin end;

function TPanickedAbility.Expand(A1: TAbilityOwner): Boolean;
begin Result := False; end;

constructor TResurrectedAbility.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TAnimatedAbility.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TCombatResurrectedAbility.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TWallClimbingAbility.Create(AOwner: Engine.TECustomNode);
begin end;

function TWallClimbingAbility.GetWallCombatFeatures(A1: TAbilityOwner): TWallCombatFeatures;
begin Result := []; end;

constructor TPassWallAbility.Create(AOwner: Engine.TECustomNode);
begin end;

function TPassWallAbility.GetWallCombatFeatures(A1: TAbilityOwner): TWallCombatFeatures;
begin Result := []; end;

constructor TVertigoAbility.Create(AOwner: Engine.TECustomNode);
begin end;

function TVertigoAbility.GetTotalDuration: Integer;
begin Result := 0; end;

function TVertigoAbility.GetAttack(A1: TAbilityOwner): Shortint;
begin Result := 0; end;

function TVertigoAbility.GetDefense(A1: TAbilityOwner): Shortint;
begin Result := 0; end;

constructor TCursedAbility.Create(AOwner: Engine.TECustomNode);
begin end;

function TCursedAbility.GetSourceName(A1: TAbilityOwner): string;
begin Result := ''; end;

function TCursedAbility.GetTotalDuration: Integer;
begin Result := 0; end;

function TCursedAbility.GetDefense(A1: TAbilityOwner): Shortint;
begin Result := 0; end;

function TCursedAbility.GetResistance(A1: TAbilityOwner): Shortint;
begin Result := 0; end;

constructor THasteAbility.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TStoneSkinAbility.Create(AOwner: Engine.TECustomNode);
begin end;

function TStoneSkinAbility.GetSourceName(A1: TAbilityOwner): string;
begin Result := ''; end;

function TStoneSkinAbility.GetDefense(A1: TAbilityOwner): Shortint;
begin Result := 0; end;

constructor TFireProtectionEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

function TFireProtectionEnchantment.GetSourceName(A1: TAbilityOwner): string;
begin Result := ''; end;

constructor TEnchantedWeaponAbility.Create(AOwner: Engine.TECustomNode);
begin end;

function TEnchantedWeaponAbility.GetAttack(A1: TAbilityOwner): Shortint;
begin Result := 0; end;

function TEnchantedWeaponAbility.GetDamage(A1: TAbilityOwner): Shortint;
begin Result := 0; end;

function TEnchantedWeaponAbility.GetAIUpkeepPriority(A1: TAbilityOwner): Integer;
begin Result := 0; end;

constructor TSummonedAbility.Create(AOwner: Engine.TECustomNode);
begin end;

function TSummonedAbility.GetDefaultManaUpkeep(AUnit: TAbstractUnit): Integer;
begin end;

function TSummonedAbility.GetDefaultDispelResistance(AUnit: TAbstractUnit): Byte;
begin end;

function TSummonedAbility.Remove(A1: TAbilityOwner): Boolean;
begin Result := False; end;

function TSummonedAbility.GetAIUpkeepPriority(A1: TAbilityOwner): Integer;
begin Result := 0; end;

procedure TSummonedAbility.UnitIndexToAIUpkeepPriority(A1: Integer);
begin end;

constructor TFuryAbility.Create(AOwner: Engine.TECustomNode);
begin end;

function TFuryAbility.GetAttack(A1: TAbilityOwner): Shortint;
begin Result := 0; end;

function TFuryAbility.GetDefense(A1: TAbilityOwner): Shortint;
begin Result := 0; end;

function TFuryAbility.GetAIUpkeepPriority(A1: TAbilityOwner): Integer;
begin Result := 0; end;

constructor TFreeMovementAbility.Create(AOwner: Engine.TECustomNode);
begin end;

constructor THolyChampionEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TUnholyChampionEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TBlessedEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

function TBlessedEnchantment.GetDefense(A1: TAbilityOwner): Shortint;
begin Result := 0; end;

function TBlessedEnchantment.GetResistance(A1: TAbilityOwner): Shortint;
begin Result := 0; end;

function TBlessedEnchantment.GetSourceName(A1: TAbilityOwner): string;
begin Result := ''; end;

function TBlessedEnchantment.GetAIUpkeepPriority(A1: TAbilityOwner): Integer;
begin Result := 0; end;

constructor TDarkGiftEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

function TDarkGiftEnchantment.GetDamage(A1: TAbilityOwner): Shortint;
begin Result := 0; end;

function TDarkGiftEnchantment.GetAIUpkeepPriority(A1: TAbilityOwner): Integer;
begin Result := 0; end;

constructor THighPrayerBlessingAbility.Create(AOwner: Engine.TECustomNode);
begin end;

function THighPrayerBlessingAbility.GetDefense(A1: TAbilityOwner): Shortint;
begin Result := 0; end;

function THighPrayerBlessingAbility.GetResistance(A1: TAbilityOwner): Shortint;
begin Result := 0; end;

constructor TConcealmentEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TFireAuraEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

function TFireAuraEnchantment.Remove(A1: TAbilityOwner): Boolean;
begin Result := False; end;

constructor TWaterWalkingEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

function TWaterWalkingEnchantment.Remove(A1: TAbilityOwner): Boolean;
begin Result := False; end;

constructor TWindWalkingEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

function TWindWalkingEnchantment.Remove(A1: TAbilityOwner): Boolean;
begin Result := False; end;

constructor TLiquidFormEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

function TLiquidFormEnchantment.Remove(A1: TAbilityOwner): Boolean;
begin Result := False; end;

function TLiquidFormEnchantment.GetAIUpkeepPriority(A1: TAbilityOwner): Integer;
begin Result := 0; end;

constructor TMarksmanshipAbility.Create(AOwner: Engine.TECustomNode);
begin end;

function TMarksmanshipAbility.GetLevelName(A1: Integer): string;
begin end;

constructor TMovementAbility.Create(AOwner: Engine.TECustomNode);
begin end;

function TMovementAbility.GetMoveTypes(A1: TAbilityOwner): TMoveTypes;
begin Result := []; end;

function TMovementAbility.GetWallCombatFeatures(A1: TAbilityOwner): TWallCombatFeatures;
begin Result := []; end;

constructor TImmunityAbility.Create(AOwner: Engine.TECustomNode);
begin end;

function TImmunityAbility.GetImmunityTypes(A1: TAbilityOwner): TDamageTypes;
begin Result := []; end;

function TImmunityAbility.GetMoveTypes(A1: TAbilityOwner): TMoveTypes;
begin Result := []; end;

constructor TProtectionAbility.Create(AOwner: Engine.TECustomNode);
begin end;

function TProtectionAbility.GetProtectionTypes(A1: TAbilityOwner): TDamageTypes;
begin Result := []; end;

procedure RegisterPassiveAbilities(A1: Integer);
begin end;

procedure UnregisterPassiveAbilities(A1: Integer);
begin end;


initialization
finalization

end.
