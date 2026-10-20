unit PassiveAb;

{ Draft declarations of PassiveAb, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

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


  { TVisionAbility (instance size 48, VMT 557B502C) }
  TVisionAbility = class(TMultiLevelAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetLevelName(A1: Integer; A2: Integer); override;
  end;

  { THolyChampionAbility (instance size 40, VMT 557B51B8) }
  THolyChampionAbility = class(TEnhancementAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CanExpand(A1: Integer); override;
  end;

  { TUnholyChampionAbility (instance size 40, VMT 557B534C) }
  TUnholyChampionAbility = class(TEnhancementAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CanExpand(A1: Integer); override;
  end;

  { TNaturesBlessingAbility (instance size 44, VMT 557B54E4) }
  TNaturesBlessingAbility = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetAttack; override;
    procedure GetDefense; override;
    procedure GetResistance; override;
    procedure Expand(A1: Integer; A2: Integer); override;
  end;

  { THighPrayerBlessingAbility (instance size 44, VMT 557B5684) }
  THighPrayerBlessingAbility = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetDefense; override;
    procedure GetResistance; override;
  end;

  { TCrusaderAbility (instance size 44, VMT 557B582C) }
  TCrusaderAbility = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure NewTurn(A1: Integer; A2: Integer); override;
    procedure Remove(A1: Integer; A2: Integer); override;
    procedure GetTotalDuration; override;
  end;

  { TBloodlustAbility (instance size 44, VMT 557B59C0) }
  TBloodlustAbility = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetAttack; override;
    procedure GetDefense; override;
    procedure GetDamage; override;
  end;

  { TPoisonedAbility (instance size 44, VMT 557B5B58) }
  TPoisonedAbility = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetAttack; override;
    procedure GetDefense; override;
    procedure GetResistance; override;
    procedure GetDamage; override;
  end;

  { TDecayAbility (instance size 44, VMT 557B5CEC) }
  TDecayAbility = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure NewCombatTurn(A1: Integer; A2: Integer); override;
    procedure CombatDone(A1: Integer); override;
  end;

  { TWebbedAbility (instance size 44, VMT 557B5E7C) }
  TWebbedAbility = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetDefense; override;
    procedure GetTotalDuration; override;
  end;

  { TStunnedAbility (instance size 44, VMT 557B600C) }
  TStunnedAbility = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetDefense; override;
    procedure GetTotalDuration; override;
  end;

  { TBurningAbility (instance size 44, VMT 557B619C) }
  TBurningAbility = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure NewCombatTurn(A1: Integer; A2: Integer); override;
    procedure GetTotalDuration; override;
  end;

  { TVertigoAbility (instance size 44, VMT 557B632C) }
  TVertigoAbility = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetAttack; override;
    procedure GetDefense; override;
    procedure GetTotalDuration; override;
  end;

  { TCursedAbility (instance size 44, VMT 557B64BC) }
  TCursedAbility = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetDefense; override;
    procedure GetResistance; override;
    procedure GetSourceName(A1: Integer; A2: Integer); override;
    procedure GetTotalDuration; override;
  end;

  { THolyFear (instance size 44, VMT 557B664C) }
  THolyFear = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetSourceName(A1: Integer; A2: Integer); override;
    procedure GetTotalDuration; override;
  end;

  { TPanickedAbility (instance size 44, VMT 557B67D4) }
  TPanickedAbility = class(TDurationAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Expand(A1: Integer; A2: Integer); override;
  end;

  { TWallClimbingAbility (instance size 40, VMT 557B6968) }
  TWallClimbingAbility = class(TAdjustableAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetWallCombatFeatures(A1: Integer); override;
  end;

  { TPassWallAbility (instance size 40, VMT 557B6AFC) }
  TPassWallAbility = class(TAdjustableAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetWallCombatFeatures(A1: Integer); override;
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
    procedure GetLevelName(A1: Integer; A2: Integer); override;
  end;

  { TMovementAbility (instance size 44, VMT 557B72DC) }
  TMovementAbility = class(TAdjustableAbility)
  public
    F_MovementAbility_28: Byte;
    F_MovementAbility_29: array[0..2] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetMoveTypes; override;
    procedure GetWallCombatFeatures(A1: Integer); override;
  end;

  { TImmunityAbility (instance size 44, VMT 557B7468) }
  TImmunityAbility = class(TEnhancementAbility)
  public
    F_ImmunityAbility_28: Word;
    F_ImmunityAbility_2A: array[0..1] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetMoveTypes; override;
    procedure GetImmunityTypes; override;
  end;

  { TProtectionAbility (instance size 44, VMT 557B75F4) }
  TProtectionAbility = class(TEnhancementAbility)
  public
    F_ProtectionAbility_28: Word;
    F_ProtectionAbility_2A: array[0..1] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetProtectionTypes; override;
  end;

  { TEntangledAbility (instance size 40, VMT 557B7784) }
  TEntangledAbility = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetDefense; override;
    procedure GetDurationMode; override;
    procedure GetTotalDuration; override;
    procedure CreateEnchantment; override;
  end;

  { TFrozenAbility (instance size 40, VMT 557B7928) }
  TFrozenAbility = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetDefense; override;
    procedure GetDurationMode; override;
    procedure GetTotalDuration; override;
    procedure CreateEnchantment; override;
  end;

  { TTurnedUndeadAbility (instance size 40, VMT 557B7AC4) }
  TTurnedUndeadAbility = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetDurationMode; override;
    procedure GetTotalDuration; override;
    procedure CreateEnchantment; override;
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
    procedure GetDefense; override;
    procedure GetSourceName(A1: Integer; A2: Integer); override;
  end;

  { TEnchantedWeaponAbility (instance size 40, VMT 557B7FAC) }
  TEnchantedWeaponAbility = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetAttack; override;
    procedure GetDamage; override;
    procedure GetAIUpkeepPriority(A1: Integer); override;
  end;

  { TSummonedAbility (instance size 40, VMT 557B8158) }
  TSummonedAbility = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Remove(A1: Integer; A2: Integer); override;
    procedure GetAIUpkeepPriority(A1: Integer); override;
    procedure GetDefaultManaUpkeep(A1: Integer);  { draft }
    procedure GetDefaultDispelResistance(A1: Integer);  { draft }
    procedure UnitIndexToAIUpkeepPriority(A1: Integer);  { draft }
  end;

  { TFuryAbility (instance size 40, VMT 557B82F8) }
  TFuryAbility = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetAttack; override;
    procedure GetDefense; override;
    procedure GetAIUpkeepPriority(A1: Integer); override;
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
    procedure Remove(A1: Integer; A2: Integer); override;
  end;

  { TWaterWalkingEnchantment (instance size 40, VMT 557B8CF0) }
  TWaterWalkingEnchantment = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Remove(A1: Integer; A2: Integer); override;
  end;

  { TWindWalkingEnchantment (instance size 40, VMT 557B8EA0) }
  TWindWalkingEnchantment = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Remove(A1: Integer; A2: Integer); override;
  end;

  { TLiquidFormEnchantment (instance size 40, VMT 557B904C) }
  TLiquidFormEnchantment = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Remove(A1: Integer; A2: Integer); override;
    procedure GetAIUpkeepPriority(A1: Integer); override;
  end;

  { TBlessedEnchantment (instance size 40, VMT 557B91F8) }
  TBlessedEnchantment = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetDefense; override;
    procedure GetResistance; override;
    procedure GetSourceName(A1: Integer; A2: Integer); override;
    procedure GetAIUpkeepPriority(A1: Integer); override;
  end;

  { TDarkGiftEnchantment (instance size 40, VMT 557B939C) }
  TDarkGiftEnchantment = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetDamage; override;
    procedure GetAIUpkeepPriority(A1: Integer); override;
  end;

  { TFireProtectionEnchantment (instance size 40, VMT 557B9544) }
  TFireProtectionEnchantment = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetSourceName(A1: Integer; A2: Integer); override;
  end;

  { TSlowEnchantmentAbility (instance size 40, VMT 557B96F8) }
  TSlowEnchantmentAbility = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CombatDone(A1: Integer); override;
    procedure CreateEnchantment; override;
  end;

procedure RegisterPassiveAbilities(A1: Integer);  { draft }
procedure UnregisterPassiveAbilities(A1: Integer);  { draft }

implementation

constructor TVisionAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TVisionAbility.GetLevelName(A1: Integer; A2: Integer);
begin end;

constructor THolyChampionAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure THolyChampionAbility.CanExpand(A1: Integer);
begin end;

constructor TUnholyChampionAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TUnholyChampionAbility.CanExpand(A1: Integer);
begin end;

constructor TNaturesBlessingAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TNaturesBlessingAbility.GetAttack;
begin end;

procedure TNaturesBlessingAbility.GetDefense;
begin end;

procedure TNaturesBlessingAbility.GetResistance;
begin end;

procedure TNaturesBlessingAbility.Expand(A1: Integer; A2: Integer);
begin end;

constructor TBloodlustAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TBloodlustAbility.GetAttack;
begin end;

procedure TBloodlustAbility.GetDefense;
begin end;

procedure TBloodlustAbility.GetDamage;
begin end;

constructor TPoisonedAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TPoisonedAbility.GetAttack;
begin end;

procedure TPoisonedAbility.GetDefense;
begin end;

procedure TPoisonedAbility.GetResistance;
begin end;

procedure TPoisonedAbility.GetDamage;
begin end;

constructor TSlowEnchantmentAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TSlowEnchantmentAbility.CreateEnchantment;
begin end;

procedure TSlowEnchantmentAbility.CombatDone(A1: Integer);
begin end;

constructor TEntangledAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TEntangledAbility.GetDurationMode;
begin end;

procedure TEntangledAbility.GetTotalDuration;
begin end;

procedure TEntangledAbility.GetDefense;
begin end;

procedure TEntangledAbility.CreateEnchantment;
begin end;

constructor TFrozenAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TFrozenAbility.GetDurationMode;
begin end;

procedure TFrozenAbility.GetTotalDuration;
begin end;

procedure TFrozenAbility.CreateEnchantment;
begin end;

procedure TFrozenAbility.GetDefense;
begin end;

constructor TTurnedUndeadAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TTurnedUndeadAbility.CreateEnchantment;
begin end;

procedure TTurnedUndeadAbility.GetDurationMode;
begin end;

procedure TTurnedUndeadAbility.GetTotalDuration;
begin end;

constructor TCrusaderAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TCrusaderAbility.Remove(A1: Integer; A2: Integer);
begin end;

procedure TCrusaderAbility.GetTotalDuration;
begin end;

procedure TCrusaderAbility.NewTurn(A1: Integer; A2: Integer);
begin end;

constructor TWebbedAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TWebbedAbility.GetTotalDuration;
begin end;

procedure TWebbedAbility.GetDefense;
begin end;

constructor TBurningAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TBurningAbility.GetTotalDuration;
begin end;

procedure TBurningAbility.NewCombatTurn(A1: Integer; A2: Integer);
begin end;

constructor TStunnedAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TStunnedAbility.GetTotalDuration;
begin end;

procedure TStunnedAbility.GetDefense;
begin end;

constructor THolyFear.Create(AOwner: Engine.TECustomNode);
begin end;

procedure THolyFear.GetTotalDuration;
begin end;

procedure THolyFear.GetSourceName(A1: Integer; A2: Integer);
begin end;

constructor TDecayAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TDecayAbility.NewCombatTurn(A1: Integer; A2: Integer);
begin end;

procedure TDecayAbility.CombatDone(A1: Integer);
begin end;

constructor TPanickedAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TPanickedAbility.Expand(A1: Integer; A2: Integer);
begin end;

constructor TResurrectedAbility.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TAnimatedAbility.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TCombatResurrectedAbility.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TWallClimbingAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TWallClimbingAbility.GetWallCombatFeatures(A1: Integer);
begin end;

constructor TPassWallAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TPassWallAbility.GetWallCombatFeatures(A1: Integer);
begin end;

constructor TVertigoAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TVertigoAbility.GetTotalDuration;
begin end;

procedure TVertigoAbility.GetAttack;
begin end;

procedure TVertigoAbility.GetDefense;
begin end;

constructor TCursedAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TCursedAbility.GetSourceName(A1: Integer; A2: Integer);
begin end;

procedure TCursedAbility.GetTotalDuration;
begin end;

procedure TCursedAbility.GetDefense;
begin end;

procedure TCursedAbility.GetResistance;
begin end;

constructor THasteAbility.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TStoneSkinAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TStoneSkinAbility.GetSourceName(A1: Integer; A2: Integer);
begin end;

procedure TStoneSkinAbility.GetDefense;
begin end;

constructor TFireProtectionEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TFireProtectionEnchantment.GetSourceName(A1: Integer; A2: Integer);
begin end;

constructor TEnchantedWeaponAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TEnchantedWeaponAbility.GetAttack;
begin end;

procedure TEnchantedWeaponAbility.GetDamage;
begin end;

procedure TEnchantedWeaponAbility.GetAIUpkeepPriority(A1: Integer);
begin end;

constructor TSummonedAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TSummonedAbility.GetDefaultManaUpkeep(A1: Integer);
begin end;

procedure TSummonedAbility.GetDefaultDispelResistance(A1: Integer);
begin end;

procedure TSummonedAbility.Remove(A1: Integer; A2: Integer);
begin end;

procedure TSummonedAbility.GetAIUpkeepPriority(A1: Integer);
begin end;

procedure TSummonedAbility.UnitIndexToAIUpkeepPriority(A1: Integer);
begin end;

constructor TFuryAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TFuryAbility.GetAttack;
begin end;

procedure TFuryAbility.GetDefense;
begin end;

procedure TFuryAbility.GetAIUpkeepPriority(A1: Integer);
begin end;

constructor TFreeMovementAbility.Create(AOwner: Engine.TECustomNode);
begin end;

constructor THolyChampionEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TUnholyChampionEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TBlessedEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TBlessedEnchantment.GetDefense;
begin end;

procedure TBlessedEnchantment.GetResistance;
begin end;

procedure TBlessedEnchantment.GetSourceName(A1: Integer; A2: Integer);
begin end;

procedure TBlessedEnchantment.GetAIUpkeepPriority(A1: Integer);
begin end;

constructor TDarkGiftEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TDarkGiftEnchantment.GetDamage;
begin end;

procedure TDarkGiftEnchantment.GetAIUpkeepPriority(A1: Integer);
begin end;

constructor THighPrayerBlessingAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure THighPrayerBlessingAbility.GetDefense;
begin end;

procedure THighPrayerBlessingAbility.GetResistance;
begin end;

constructor TConcealmentEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TFireAuraEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TFireAuraEnchantment.Remove(A1: Integer; A2: Integer);
begin end;

constructor TWaterWalkingEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TWaterWalkingEnchantment.Remove(A1: Integer; A2: Integer);
begin end;

constructor TWindWalkingEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TWindWalkingEnchantment.Remove(A1: Integer; A2: Integer);
begin end;

constructor TLiquidFormEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TLiquidFormEnchantment.Remove(A1: Integer; A2: Integer);
begin end;

procedure TLiquidFormEnchantment.GetAIUpkeepPriority(A1: Integer);
begin end;

constructor TMarksmanshipAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TMarksmanshipAbility.GetLevelName(A1: Integer; A2: Integer);
begin end;

constructor TMovementAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TMovementAbility.GetMoveTypes;
begin end;

procedure TMovementAbility.GetWallCombatFeatures(A1: Integer);
begin end;

constructor TImmunityAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TImmunityAbility.GetImmunityTypes;
begin end;

procedure TImmunityAbility.GetMoveTypes;
begin end;

constructor TProtectionAbility.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TProtectionAbility.GetProtectionTypes;
begin end;

procedure RegisterPassiveAbilities(A1: Integer);
begin end;

procedure UnregisterPassiveAbilities(A1: Integer);
begin end;


initialization
finalization

end.
