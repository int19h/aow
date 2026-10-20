unit UnitSpells;

{ Draft declarations of UnitSpells, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  THaste through TCosmeticSurgery and TDispelMagicSpellCA are recovered;
  TDispelMagic and registration remain drafts. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TDispelMagicSpellCA = class;
  TDispelMagic = class;
  THaste = class;
  TStoneSkin = class;
  TEnchantWeapon = class;
  TFreeMovement = class;
  TFury = class;
  TRemedy = class;
  THealingWater = class;
  THolyChampion = class;
  TUnholyChampion = class;
  TConcealment = class;
  TFireAura = class;
  TWaterWalking = class;
  TWindWalking = class;
  TLiquidForm = class;
  TBless = class;
  TDarkGift = class;
  TCosmeticSurgerySpellCaster = class;
  TCosmeticSurgery = class;


  { TDispelMagicSpellCA (instance size 28, VMT 557E530C):
    $14 spell ID, $18 mana cost charged after execution. }
  TDispelMagicSpellCA = class(TDispelMagicCA)
  public
    FSpellID: Integer; { $14 }
    FManaCost: Integer; { $18 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
  end;

  { TDispelMagic (instance size 68, VMT 557E53F4) }
  TDispelMagic = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateCA(A1: Integer; A2: Integer; A3: Integer); override;
    procedure GetCombatInfo(Source: TCombatObject; var Info: TSpellCombatInfo); override;
    function ValidTargetUnit(Source, Target: TAbstractUnit): Boolean; override;
    procedure ValidTargetParty(A1: Integer; A2: Integer); override;
    function ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean; override;
    procedure GetDispelMana(A1: Integer);  { draft }
  end;

  { THaste (instance size 68, VMT 557E5534) }
  THaste = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ValidTargetUnit(Source, Target: TAbstractUnit): Boolean; override;
    function ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean; override;
  end;

  { TStoneSkin (instance size 68, VMT 557E5664) }
  TStoneSkin = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ValidTargetUnit(Source, Target: TAbstractUnit): Boolean; override;
    function ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean; override;
  end;

  { TEnchantWeapon (instance size 68, VMT 557E579C) }
  TEnchantWeapon = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ValidTargetUnit(Source, Target: TAbstractUnit): Boolean; override;
    function ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean; override;
  end;

  { TFreeMovement (instance size 68, VMT 557E58DC) }
  TFreeMovement = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ValidTargetUnit(Source, Target: TAbstractUnit): Boolean; override;
    function ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean; override;
  end;

  { TFury (instance size 68, VMT 557E5A1C) }
  TFury = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure PlayDefaultCastEffects(Player, X, Y, Layer: Shortint); override;
    function ValidTargetUnit(Source, Target: TAbstractUnit): Boolean; override;
    function ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean; override;
  end;

  { TRemedy (instance size 68, VMT 557E5B4C) }
  TRemedy = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ValidTargetUnit(Source, Target: TAbstractUnit): Boolean; override;
    function ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean; override;
  end;

  { THealingWater (instance size 68, VMT 557E5C7C) }
  THealingWater = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ValidTargetUnit(Source, Target: TAbstractUnit): Boolean; override;
    function ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean; override;
  end;

  { THolyChampion (instance size 68, VMT 557E5DBC) }
  THolyChampion = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ValidTargetUnit(Source, Target: TAbstractUnit): Boolean; override;
    function ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean; override;
  end;

  { TUnholyChampion (instance size 68, VMT 557E5EFC) }
  TUnholyChampion = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ValidTargetUnit(Source, Target: TAbstractUnit): Boolean; override;
    function ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean; override;
  end;

  { TConcealment (instance size 68, VMT 557E603C) }
  TConcealment = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ValidTargetUnit(Source, Target: TAbstractUnit): Boolean; override;
    function ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean; override;
  end;

  { TFireAura (instance size 68, VMT 557E617C) }
  TFireAura = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure PlayDefaultCastEffects(Player, X, Y, Layer: Shortint); override;
    function ValidTargetUnit(Source, Target: TAbstractUnit): Boolean; override;
    function ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean; override;
  end;

  { TWaterWalking (instance size 68, VMT 557E62B4) }
  TWaterWalking = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ValidTargetUnit(Source, Target: TAbstractUnit): Boolean; override;
    function ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean; override;
  end;

  { TWindWalking (instance size 68, VMT 557E63F4) }
  TWindWalking = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ValidTargetUnit(Source, Target: TAbstractUnit): Boolean; override;
    function ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean; override;
  end;

  { TLiquidForm (instance size 68, VMT 557E6534) }
  TLiquidForm = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure PlayDefaultCastEffects(Player, X, Y, Layer: Shortint); override;
    function ValidTargetUnit(Source, Target: TAbstractUnit): Boolean; override;
    function ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean; override;
  end;

  { TBless (instance size 68, VMT 557E666C) }
  TBless = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ValidTargetUnit(Source, Target: TAbstractUnit): Boolean; override;
    function ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean; override;
  end;

  { TDarkGift (instance size 68, VMT 557E679C) }
  TDarkGift = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ValidTargetUnit(Source, Target: TAbstractUnit): Boolean; override;
    function ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean; override;
  end;

  { TCosmeticSurgerySpellCaster (instance size 28, VMT 557E68D4):
    $14 replacement face index, $18 target unit ID. }
  TCosmeticSurgerySpellCaster = class(TSpellCaster)
  public
    FFaceIndex: Integer; { $14 }
    FTargetUnitID: Integer; { $18 }
    function CanCast(var Reason: string): Boolean; override;
    function Cast: Boolean; override;
  end;

  { TCosmeticSurgery (instance size 68, VMT 557E69BC) }
  TCosmeticSurgery = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetCombatInfo(Source: TCombatObject; var Info: TSpellCombatInfo); override;
    function ValidTargetUnit(Source, Target: TAbstractUnit): Boolean; override;
    function CastSpell(Source: TAbstractUnit; Targets: TUnitList): Boolean; override;
    function ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean; override;
  end;

procedure RegisterUnitSpells(A1: Integer; A2: Integer; A3: Integer);  { draft }
procedure UnregisterUnitSpells(A1: Integer; A2: Integer; A3: Integer);  { draft }

implementation

constructor THaste.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellControlTypes := [sctGlobal, sctCombat];
  FSpellName := TranslateRStr(HasteRStr);
  FSpellID := 15;
  FBaseManaCost := 5;
  FManaUpkeep := 2;
  FSpellLevel := 1;
  FMagicSphere := msAir;
  FTargetRange := 12;
  FUnitDispelResistance := 3;
end;

function THaste.ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean;
var
  Enchantment: TUnitEnchantment;
begin
  if ValidTargetUnit(Source, Target) then
  begin
    if Target.ExpandAbility(152) then
    begin
      Enchantment := TUnitEnchantmentAbilityData(Target.GetAbilityData(152)).FEnchantment;
      Enchantment.SetUpkeep(FManaUpkeep);
      Enchantment.SetSource(Source.FPlayer);
      Enchantment.FDispelResistance := FUnitDispelResistance;
      Result := True;
    end
    else
      Result := False;
  end
  else
    Result := False;
end;

function THaste.ValidTargetUnit(Source, Target: TAbstractUnit): Boolean;
begin
  Result := inherited ValidTargetUnit(Source, Target);
  Result := Result and not Target.GetAbilityEnabled(152);
end;

constructor TStoneSkin.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(StoneSkinRStr);
  FSpellID := 17;
  FBaseManaCost := 5;
  FSpellLevel := 1;
  FMagicSphere := msEarth;
  FTargetRange := 12;
  FSpellControlTypes := [sctGlobal, sctCombat];
  FUnitDispelResistance := 3;
  FAIValue := 200;
  FCastDuration := 5;
end;

function TStoneSkin.ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean;
var
  Enchantment: TUnitEnchantment;
begin
  if ValidTargetUnit(Source, Target) then
  begin
    if Target.ExpandAbility(153) then
    begin
      Enchantment := TUnitEnchantmentAbilityData(Target.GetAbilityData(153)).FEnchantment;
      Enchantment.SetUpkeep(FManaUpkeep);
      Enchantment.SetSource(Source.FPlayer);
      Enchantment.FDispelResistance := FUnitDispelResistance;
    end;
    Result := True; { Original succeeds even when expansion fails. }
  end
  else
    Result := False;
end;

function TStoneSkin.ValidTargetUnit(Source, Target: TAbstractUnit): Boolean;
begin
  Result := inherited ValidTargetUnit(Source, Target);
  Result := Result and not Target.GetAbilityEnabled(153);
end;

constructor TEnchantWeapon.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(EnchantWeaponRStr);
  FSpellID := 16;
  FBaseManaCost := 5;
  FSpellLevel := 1;
  FMagicSphere := msCosmos;
  FTargetRange := 12;
  FSpellControlTypes := [sctGlobal, sctCombat];
  FUnitDispelResistance := 3;
  FAIValue := 225;
  FCastDuration := 5;
end;

function TEnchantWeapon.ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean;
var
  Enchantment: TUnitEnchantment;
begin
  if ValidTargetUnit(Source, Target) then
  begin
    if Target.ExpandAbility(154) then
    begin
      Enchantment := TUnitEnchantmentAbilityData(Target.GetAbilityData(154)).FEnchantment;
      Enchantment.SetUpkeep(FManaUpkeep);
      Enchantment.SetSource(Source.FPlayer);
      Enchantment.FDispelResistance := FUnitDispelResistance;
    end;
    Result := True; { Original succeeds even when expansion fails. }
  end
  else
    Result := False;
end;

function TEnchantWeapon.ValidTargetUnit(Source, Target: TAbstractUnit): Boolean;
begin
  Result := inherited ValidTargetUnit(Source, Target);
  Result := Result and not Target.GetAbilityEnabled(154) and Target.GetAbilityEnabled(21);
end;

constructor TFury.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(FuryRStr);
  FSpellID := 33;
  FAIValue := 175;
  FBaseManaCost := 5;
  FSpellLevel := 1;
  FMagicSphere := msFire;
  FTargetRange := 12;
  FSpellControlTypes := [sctGlobal, sctCombat];
  FUnitDispelResistance := 3;
end;

function TFury.ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean;
var
  Enchantment: TUnitEnchantment;
begin
  if ValidTargetUnit(Source, Target) then
  begin
    if Target.ExpandAbility(156) then
    begin
      Enchantment := TUnitEnchantmentAbilityData(Target.GetAbilityData(156)).FEnchantment;
      Enchantment.SetUpkeep(FManaUpkeep);
      Enchantment.SetSource(Source.FPlayer);
      Enchantment.FDispelResistance := FUnitDispelResistance;
    end;
    Result := True; { Original succeeds even when expansion fails. }
  end
  else
    Result := False;
end;

procedure TFury.PlayDefaultCastEffects(Player, X, Y, Layer: Shortint);
begin
  inherited PlayDefaultCastEffects(Player, X, Y, Layer);
  if (Player = AoWHSMap.FSeatedPlayer) or AoWHSMap.Watching(X, Y, Layer, 0) then
    AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastSounds.Play(1);
end;

function TFury.ValidTargetUnit(Source, Target: TAbstractUnit): Boolean;
begin
  Result := inherited ValidTargetUnit(Source, Target);
  Result := Result and not Target.GetAbilityEnabled(156);
  if Result then
    if (AoWHSMap.FPlayers.GetPlayers(Target.FPlayer).FPlayerType <> ptHuman) and
      (Target is TLeader) then
      Result := False;
end;

constructor TFreeMovement.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(FreeMovementRStr);
  FSpellID := 32;
  FBaseManaCost := 5;
  FSpellLevel := 2;
  FMagicSphere := msEarth;
  FTargetRange := 12;
  FSpellControlTypes := [sctGlobal, sctCombat];
  FUnitDispelResistance := 4;
end;

function TFreeMovement.ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean;
var
  Enchantment: TUnitEnchantment;
begin
  if ValidTargetUnit(Source, Target) then
  begin
    if Target.ExpandAbility(157) then
    begin
      Enchantment := TUnitEnchantmentAbilityData(Target.GetAbilityData(157)).FEnchantment;
      Enchantment.SetUpkeep(FManaUpkeep);
      Enchantment.SetSource(Source.FPlayer);
      Enchantment.FDispelResistance := FUnitDispelResistance;
    end;
    Result := True; { Original succeeds even when expansion fails. }
  end
  else
    Result := False;
end;

function TFreeMovement.ValidTargetUnit(Source, Target: TAbstractUnit): Boolean;
begin
  Result := inherited ValidTargetUnit(Source, Target);
  Result := Result and not Target.GetAbilityEnabled(157) and (not Target.GetAbilityEnabled(3) or not Target.GetAbilityEnabled(5) or not Target.GetAbilityEnabled(4));
end;

constructor TRemedy.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(RemedyRStr);
  FSpellID := 35;
  FBaseManaCost := 5;
  FSpellLevel := 1;
  FMagicSphere := msCosmos;
  FTargetRange := 12;
  FSpellControlTypes := [sctGlobal, sctCombat];
end;

function TRemedy.ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean;
var
  HitPoints: Integer;
begin
  if ValidTargetUnit(Source, Target) then
  begin
    HitPoints := Target.GetHitPoints + 5;
    if HitPoints > Target.GetHits then
      HitPoints := Target.GetHits;
    Target.SetHitPoints(HitPoints);
    Target.RemoveAbility(93);
    Target.RemoveAbility(96);
    Target.RemoveAbility(108);
    Target.RemoveAbility(53);
    Target.RemoveAbility(92);
    Target.RemoveAbility(127);
    Result := True;
  end
  else
    Result := False;
end;

function TRemedy.ValidTargetUnit(Source, Target: TAbstractUnit): Boolean;
begin
  Result := inherited ValidTargetUnit(Source, Target);
  Result := Result and ((Target.GetHitPoints <> Target.GetHits) or
    Target.GetAbilityEnabled(96) or Target.GetAbilityEnabled(92) or
    Target.GetAbilityEnabled(108) or Target.GetAbilityEnabled(53) or
    Target.GetAbilityEnabled(93) or Target.GetAbilityEnabled(127));
end;

constructor THealingWater.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(HealingWaterRStr);
  FSpellID := 55;
  FBaseManaCost := 5;
  FSpellLevel := 1;
  FMagicSphere := msCosmos;
  FTargetRange := 12;
  FSpellControlTypes := [sctGlobal, sctCombat];
end;

function THealingWater.ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean;
begin
  if ValidTargetUnit(Source, Target) then
  begin
    Target.RemoveAbility(127);
    Target.SetHitPoints(Target.GetHits);
    Result := True;
  end
  else
    Result := False;
end;

function THealingWater.ValidTargetUnit(Source, Target: TAbstractUnit): Boolean;
begin
  Result := inherited ValidTargetUnit(Source, Target);
  Result := Result and ((Target.GetHitPoints <> Target.GetHits) or Target.GetAbilityEnabled(127));
end;

constructor THolyChampion.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(HolyChampionRStr);
  FSpellID := 36;
  FBaseManaCost := 5;
  FSpellLevel := 2;
  FMagicSphere := msLife;
  FTargetRange := 12;
  FUnitDispelResistance := 4;
  FSpellControlTypes := [sctGlobal, sctCombat];
end;

function THolyChampion.ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean;
var
  Enchantment: TUnitEnchantment;
begin
  if ValidTargetUnit(Source, Target) then
  begin
    if Target.ExpandAbility(160) then
    begin
      Enchantment := TUnitEnchantmentAbilityData(Target.GetAbilityData(160)).FEnchantment;
      Enchantment.SetUpkeep(FManaUpkeep);
      Enchantment.SetSource(Source.FPlayer);
      Enchantment.FDispelResistance := FUnitDispelResistance;
    end;
    Result := True; { Original succeeds even when expansion fails. }
  end
  else
    Result := False;
end;

function THolyChampion.ValidTargetUnit(Source, Target: TAbstractUnit): Boolean;
begin
  Result := inherited ValidTargetUnit(Source, Target);
  Result := Result and not Target.GetAbilityEnabled(146) and
    not Target.GetAbilityEnabled(160) and
    AoWHSSet.FAbilityControl.GetAbility(146).CanExpand(Target);
end;

constructor TUnholyChampion.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(UnholyChampionRStr);
  FSpellID := 37;
  FBaseManaCost := 5;
  FSpellLevel := 2;
  FMagicSphere := msDeath;
  FTargetRange := 12;
  FUnitDispelResistance := 4;
  FSpellControlTypes := [sctGlobal, sctCombat];
end;

function TUnholyChampion.ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean;
var
  Enchantment: TUnitEnchantment;
begin
  if ValidTargetUnit(Source, Target) then
  begin
    if Target.ExpandAbility(161) then
    begin
      Enchantment := TUnitEnchantmentAbilityData(Target.GetAbilityData(161)).FEnchantment;
      Enchantment.SetUpkeep(FManaUpkeep);
      Enchantment.SetSource(Source.FPlayer);
      Enchantment.FDispelResistance := FUnitDispelResistance;
    end;
    Result := True; { Original succeeds even when expansion fails. }
  end
  else
    Result := False;
end;

function TUnholyChampion.ValidTargetUnit(Source, Target: TAbstractUnit): Boolean;
begin
  Result := inherited ValidTargetUnit(Source, Target);
  Result := Result and not Target.GetAbilityEnabled(147) and
    not Target.GetAbilityEnabled(161) and
    AoWHSSet.FAbilityControl.GetAbility(147).CanExpand(Target);
end;

constructor TConcealment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(ConcealmentRStr);
  FSpellID := 39;
  FBaseManaCost := 5;
  FSpellLevel := 3;
  FMagicSphere := msEarth;
  FTargetRange := 12;
  FUnitDispelResistance := 5;
  FSpellControlTypes := [sctGlobal];
end;

function TConcealment.ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean;
var
  Enchantment: TUnitEnchantment;
begin
  if ValidTargetUnit(Source, Target) then
  begin
    if Target.ExpandAbility(162) then
    begin
      Enchantment := TUnitEnchantmentAbilityData(Target.GetAbilityData(162)).FEnchantment;
      Enchantment.SetUpkeep(FManaUpkeep);
      Enchantment.SetSource(Source.FPlayer);
      Enchantment.FDispelResistance := FUnitDispelResistance;
    end;
    Result := True; { Original succeeds even when expansion fails. }
  end
  else
    Result := False;
end;

function TConcealment.ValidTargetUnit(Source, Target: TAbstractUnit): Boolean;
begin
  Result := inherited ValidTargetUnit(Source, Target);
  Result := Result and not Target.GetAbilityEnabled(145) and
    not Target.GetAbilityEnabled(162) and not Target.GetAbilityEnabled(54);
end;

constructor TFireAura.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(FireAuraRStr);
  FSpellID := 40;
  FBaseManaCost := 5;
  FSpellLevel := 2;
  FMagicSphere := msFire;
  FTargetRange := 12;
  FUnitDispelResistance := 4;
  FSpellControlTypes := [sctGlobal, sctCombat];
end;

procedure TFireAura.PlayDefaultCastEffects(Player, X, Y, Layer: Shortint);
begin
  inherited PlayDefaultCastEffects(Player, X, Y, Layer);
  if (Player = AoWHSMap.FSeatedPlayer) or AoWHSMap.Watching(X, Y, Layer, 0) then
    AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastSounds.Play(1);
end;

function TFireAura.ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean;
var
  Enchantment: TUnitEnchantment;
begin
  if ValidTargetUnit(Source, Target) then
  begin
    if Target.ExpandAbility(163) then
    begin
      Enchantment := TUnitEnchantmentAbilityData(Target.GetAbilityData(163)).FEnchantment;
      Enchantment.SetUpkeep(FManaUpkeep);
      Enchantment.SetSource(Source.FPlayer);
      Enchantment.FDispelResistance := FUnitDispelResistance;
    end;
    Result := True; { Original succeeds even when expansion fails. }
  end
  else
    Result := False;
end;

function TFireAura.ValidTargetUnit(Source, Target: TAbstractUnit): Boolean;
begin
  Result := inherited ValidTargetUnit(Source, Target);
  Result := Result and (not Target.GetAbilityEnabled(7) or not Target.GetAbilityEnabled(43)) and
    not Target.GetAbilityEnabled(163);
end;

constructor TWaterWalking.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(WaterWalkingRStr);
  FSpellID := 42;
  FBaseManaCost := 5;
  FSpellLevel := 2;
  FMagicSphere := msWater;
  FTargetRange := 12;
  FUnitDispelResistance := 6;
  FSpellControlTypes := [sctGlobal, sctCombat];
end;

function TWaterWalking.ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean;
var
  Enchantment: TUnitEnchantment;
begin
  if ValidTargetUnit(Source, Target) then
  begin
    if Target.ExpandAbility(164) then
    begin
      Enchantment := TUnitEnchantmentAbilityData(Target.GetAbilityData(164)).FEnchantment;
      Enchantment.SetUpkeep(FManaUpkeep);
      Enchantment.SetSource(Source.FPlayer);
      Enchantment.FDispelResistance := FUnitDispelResistance;
    end;
    Result := True; { Original succeeds even when expansion fails. }
  end
  else
    Result := False;
end;

function TWaterWalking.ValidTargetUnit(Source, Target: TAbstractUnit): Boolean;
begin
  Result := inherited ValidTargetUnit(Source, Target);
  Result := Result and not Target.GetAbilityEnabled(23) and not Target.GetAbilityEnabled(2) and
    not Target.GetAbilityEnabled(164) and not Target.GetAbilityEnabled(1) and
    not Target.GetAbilityEnabled(59);
end;

constructor TWindWalking.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(WindWalkingRStr);
  FSpellID := 43;
  FBaseManaCost := 5;
  FSpellLevel := 3;
  FMagicSphere := msAir;
  FTargetRange := 12;
  FUnitDispelResistance := 6;
  FSpellControlTypes := [sctGlobal, sctCombat];
end;

function TWindWalking.ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean;
var
  Enchantment: TUnitEnchantment;
begin
  if ValidTargetUnit(Source, Target) then
  begin
    if Target.ExpandAbility(165) then
    begin
      Enchantment := TUnitEnchantmentAbilityData(Target.GetAbilityData(165)).FEnchantment;
      Enchantment.SetUpkeep(FManaUpkeep);
      Enchantment.SetSource(Source.FPlayer);
      Enchantment.FDispelResistance := FUnitDispelResistance;
    end;
    Result := True; { Original succeeds even when expansion fails. }
  end
  else
    Result := False;
end;

function TWindWalking.ValidTargetUnit(Source, Target: TAbstractUnit): Boolean;
begin
  Result := inherited ValidTargetUnit(Source, Target);
  Result := Result and not Target.GetAbilityEnabled(1) and not Target.GetAbilityEnabled(165) and
    not Target.GetAbilityEnabled(59);
end;

constructor TLiquidForm.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(LiquidFormRStr);
  FSpellID := 49;
  FBaseManaCost := 5;
  FSpellLevel := 3;
  FMagicSphere := msWater;
  FAIValue := 300;
  FTargetRange := 12;
  FUnitDispelResistance := 5;
  FSpellControlTypes := [sctGlobal, sctCombat];
end;

function TLiquidForm.ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean;
var
  Enchantment: TUnitEnchantment;
begin
  if ValidTargetUnit(Source, Target) then
  begin
    if Target.ExpandAbility(166) then
    begin
      Enchantment := TUnitEnchantmentAbilityData(Target.GetAbilityData(166)).FEnchantment;
      Enchantment.SetUpkeep(FManaUpkeep);
      Enchantment.SetSource(Source.FPlayer);
      Enchantment.FDispelResistance := FUnitDispelResistance;
    end;
    Result := True; { Original succeeds even when expansion fails. }
  end
  else
    Result := False;
end;

function TLiquidForm.ValidTargetUnit(Source, Target: TAbstractUnit): Boolean;
begin
  Result := inherited ValidTargetUnit(Source, Target);
  Result := Result and not Target.GetAbilityEnabled(166);
  Result := Result and ((not Target.GetAbilityEnabled(13) and not Target.GetAbilityEnabled(77)) or
    (not Target.GetAbilityEnabled(2) and not Target.GetAbilityEnabled(1) and
     not Target.GetAbilityEnabled(59)));
end;

procedure TLiquidForm.PlayDefaultCastEffects(Player, X, Y, Layer: Shortint);
begin
  inherited PlayDefaultCastEffects(Player, X, Y, Layer);
  if (Player = AoWHSMap.FSeatedPlayer) or AoWHSMap.Watching(X, Y, Layer, 0) then
    AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastSounds.Play(1);
end;

constructor TBless.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(BlessRStr);
  FSpellID := 56;
  FBaseManaCost := 5;
  FSpellLevel := 3;
  FMagicSphere := msWater;
  FTargetRange := 12;
  FUnitDispelResistance := 3;
  FSpellControlTypes := [sctGlobal, sctCombat];
  FAIValue := 225;
  FCastDuration := 5;
end;

function TBless.ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean;
var
  Enchantment: TUnitEnchantment;
begin
  if ValidTargetUnit(Source, Target) then
  begin
    if Target.ExpandAbility(158) then
    begin
      Enchantment := TUnitEnchantmentAbilityData(Target.GetAbilityData(158)).FEnchantment;
      Enchantment.SetUpkeep(FManaUpkeep);
      Enchantment.SetSource(Source.FPlayer);
      Enchantment.FDispelResistance := FUnitDispelResistance;
    end;
    Result := True; { Original succeeds even when expansion fails. }
  end
  else
    Result := False;
end;

function TBless.ValidTargetUnit(Source, Target: TAbstractUnit): Boolean;
begin
  Result := inherited ValidTargetUnit(Source, Target);
  Result := Result and not Target.GetAbilityEnabled(158);
end;

constructor TDarkGift.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(DarkGiftRStr);
  FSpellID := 77;
  FBaseManaCost := 5;
  FSpellLevel := 3;
  FMagicSphere := msDeath;
  FTargetRange := 12;
  FUnitDispelResistance := 3;
  FSpellControlTypes := [sctGlobal, sctCombat];
  FAIValue := 225;
  FCastDuration := 5;
end;

function TDarkGift.ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean;
var
  Enchantment: TUnitEnchantment;
begin
  if ValidTargetUnit(Source, Target) then
  begin
    if Target.ExpandAbility(169) then
    begin
      Enchantment := TUnitEnchantmentAbilityData(Target.GetAbilityData(169)).FEnchantment;
      Enchantment.SetUpkeep(FManaUpkeep);
      Enchantment.SetSource(Source.FPlayer);
      Enchantment.FDispelResistance := FUnitDispelResistance;
    end;
    Result := True; { Original succeeds even when expansion fails. }
  end
  else
    Result := False;
end;

function TDarkGift.ValidTargetUnit(Source, Target: TAbstractUnit): Boolean;
begin
  Result := inherited ValidTargetUnit(Source, Target);
  Result := Result and not Target.GetAbilityEnabled(169);
end;

function TCosmeticSurgerySpellCaster.CanCast(var Reason: string): Boolean;
begin
  Result := inherited CanCast(Reason);
end;

function TCosmeticSurgerySpellCaster.Cast: Boolean;
var
  Source, Target: TAbstractUnit;
  Event: TUnitSpellTE;
  Reason: string;
begin
  TUnitSpell(AoWHSSet.FSpellControl.GetSpell(59)).ResetTargetSelection;
  Source := AoWHSMap.FUnitControl.FindUnit(FCasterSourceID);
  Target := AoWHSMap.FUnitControl.FindUnit(FTargetUnitID);
  if (Source <> nil) and (Target <> nil) and CanCast(Reason) and
    not AoWHSMap.FPlayers.GetPlayers(Source.FPlayer).GetBusy then
  begin
    Event := TUnitSpellTE.Create(nil);
    Event.Initialize(FCasterSpellID, Source, nil,
      AoWHSSet.FSpellControl.GetSpell(59).FBaseManaCost);
    Event.FTargetUnitIDs.Add(FTargetUnitID);
    Event.FSpellData[0] := FFaceIndex;
    Event.FTargetPlayer := Target.FPlayer;
    AoWHSMap.FTokenManager.GetTokenControl(Source.FPlayer).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else
    Result := False;
end;

constructor TCosmeticSurgery.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(DeformFaceRStr);
  FSpellID := 59;
  FSpellType := stUnit;
  FSpellLevel := 1;
  FMagicSphere := msSecret;
  FAllowMultipleTargets := False;
  FUnitDispelResistance := 10;
  FTargetRange := -1;
  FSpellControlTypes := [sctGlobal];
end;

function TCosmeticSurgery.ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean;
var
  Enchantment: TCosmeticSurgeryEnchantment;
  Expanded: Boolean;
begin
  if ValidTargetUnit(Source, Target) then
  begin
    if not Target.GetAbilityEnabled(126) then
      Expanded := Target.ExpandAbility(126)
    else
      Expanded := True;
    if Expanded then
    begin
      Enchantment := TCosmeticSurgeryEnchantment(TUnitEnchantmentAbilityData(
        Target.GetAbilityData(126)).FEnchantment);
      Enchantment.SetUpkeep(FManaUpkeep);
      Enchantment.FFaceIndex := Data[0];
      Enchantment.SetSource(Source.FPlayer);
    end;
    Result := True; { Original succeeds even when expansion fails. }
  end
  else
    Result := False;
end;

function TCosmeticSurgery.ValidTargetUnit(Source, Target: TAbstractUnit): Boolean;
begin
  Result := inherited ValidTargetUnit(Source, Target);
  Result := Result and (Target.GetUnitType in [utHumanoid, utCreature]);
end;

function TCosmeticSurgery.CastSpell(Source: TAbstractUnit; Targets: TUnitList): Boolean;
var
  Caster: TCosmeticSurgerySpellCaster;
begin
  if Targets.GetCount = 1 then
  begin
    Caster := TCosmeticSurgerySpellCaster.Create(nil);
    Caster.FCasterSourceID := Source.FUnitID;
    Caster.FCasterSpellID := FSpellID;
    Caster.FTargetUnitID := Targets.GetUnit(0).FUnitID;
    if Targets.GetUnit(0) is THero then
      Caster.FFaceIndex := THero(Targets.GetUnit(0)).FFaceIndex
    else
      Caster.FFaceIndex := 0;
    AoWHSMap.FCosmeticSurgeryEvents.TriggerNotifyEvents(Caster);
    Caster.Release;
    Result := True;
  end
  else
    Result := False;
end;

procedure TCosmeticSurgery.GetCombatInfo(Source: TCombatObject; var Info: TSpellCombatInfo);
{ The original saves Self and Source as well as Info; this compiler saves only Info. }
begin
  inherited;
  Info.TargetTypes := [cttEnemy];
end;

class function TDispelMagicSpellCA.ClassID: Integer;
begin
  Result := $202D1;
end;

procedure TDispelMagicSpellCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FSpellID, 60);
  Stream.rwInteger(FManaCost, 61);
end;

procedure TDispelMagicSpellCA.Execute(A1: TCombat);
var
  Source: TCombatUnit;
begin
  inherited Execute(A1);
  if (FManaCost <> 0) and (cExecuting in A1.FStatus) then
    if AoWHSSet.FSpellControl.GetSpell(FSpellID) <> nil then
    begin
      Source := TCombatUnit(A1.FCombatData.FindID(FSourceID));
      AoWHSSet.FSpellControl.GetSpell(FSpellID).CastingDone(Source.FUnit, FManaCost);
    end;
end;

constructor TDispelMagic.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TDispelMagic.GetDispelMana(A1: Integer);
begin end;

procedure TDispelMagic.ValidTargetParty(A1: Integer; A2: Integer);
begin end;

procedure TDispelMagic.CreateCA(A1: Integer; A2: Integer; A3: Integer);
begin end;

function TDispelMagic.ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean;
begin Result := False; end;

function TDispelMagic.ValidTargetUnit(Source, Target: TAbstractUnit): Boolean;
begin Result := False; end;

procedure TDispelMagic.GetCombatInfo(Source: TCombatObject; var Info: TSpellCombatInfo);
begin end;

procedure RegisterUnitSpells(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure UnregisterUnitSpells(A1: Integer; A2: Integer; A3: Integer);
begin end;


initialization
finalization

end.
