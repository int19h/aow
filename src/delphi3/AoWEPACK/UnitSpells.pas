unit UnitSpells;

{ Draft declarations of UnitSpells, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

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


  { TDispelMagicSpellCA (instance size 28, VMT 557E530C) }
  TDispelMagicSpellCA = class(TDispelMagicCA)
  public
    F_DispelMagicSpellCA_14: Integer;
    F_DispelMagicSpellCA_18: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat; A2: Integer); override;
  end;

  { TDispelMagic (instance size 68, VMT 557E53F4) }
  TDispelMagic = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateCA(A1: Integer; A2: Integer; A3: Integer); override;
    procedure GetCombatInfo(A1: Integer; A2: Integer); override;
    procedure ValidTargetUnit(A1: Integer; A2: Integer); override;
    procedure ValidTargetParty(A1: Integer; A2: Integer); override;
    procedure ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetDispelMana(A1: Integer);  { draft }
  end;

  { THaste (instance size 68, VMT 557E5534) }
  THaste = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ValidTargetUnit(A1: Integer; A2: Integer); override;
    procedure ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

  { TStoneSkin (instance size 68, VMT 557E5664) }
  TStoneSkin = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ValidTargetUnit(A1: Integer; A2: Integer); override;
    procedure ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

  { TEnchantWeapon (instance size 68, VMT 557E579C) }
  TEnchantWeapon = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ValidTargetUnit(A1: Integer; A2: Integer); override;
    procedure ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

  { TFreeMovement (instance size 68, VMT 557E58DC) }
  TFreeMovement = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ValidTargetUnit(A1: Integer; A2: Integer); override;
    procedure ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

  { TFury (instance size 68, VMT 557E5A1C) }
  TFury = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure PlayDefaultCastEffects(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ValidTargetUnit(A1: Integer; A2: Integer); override;
    procedure ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

  { TRemedy (instance size 68, VMT 557E5B4C) }
  TRemedy = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ValidTargetUnit(A1: Integer; A2: Integer); override;
    procedure ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

  { THealingWater (instance size 68, VMT 557E5C7C) }
  THealingWater = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ValidTargetUnit(A1: Integer; A2: Integer); override;
    procedure ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

  { THolyChampion (instance size 68, VMT 557E5DBC) }
  THolyChampion = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ValidTargetUnit(A1: Integer; A2: Integer); override;
    procedure ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

  { TUnholyChampion (instance size 68, VMT 557E5EFC) }
  TUnholyChampion = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ValidTargetUnit(A1: Integer; A2: Integer); override;
    procedure ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

  { TConcealment (instance size 68, VMT 557E603C) }
  TConcealment = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ValidTargetUnit(A1: Integer; A2: Integer); override;
    procedure ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

  { TFireAura (instance size 68, VMT 557E617C) }
  TFireAura = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure PlayDefaultCastEffects(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ValidTargetUnit(A1: Integer; A2: Integer); override;
    procedure ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

  { TWaterWalking (instance size 68, VMT 557E62B4) }
  TWaterWalking = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ValidTargetUnit(A1: Integer; A2: Integer); override;
    procedure ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

  { TWindWalking (instance size 68, VMT 557E63F4) }
  TWindWalking = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ValidTargetUnit(A1: Integer; A2: Integer); override;
    procedure ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

  { TLiquidForm (instance size 68, VMT 557E6534) }
  TLiquidForm = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure PlayDefaultCastEffects(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ValidTargetUnit(A1: Integer; A2: Integer); override;
    procedure ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

  { TBless (instance size 68, VMT 557E666C) }
  TBless = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ValidTargetUnit(A1: Integer; A2: Integer); override;
    procedure ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

  { TDarkGift (instance size 68, VMT 557E679C) }
  TDarkGift = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ValidTargetUnit(A1: Integer; A2: Integer); override;
    procedure ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

  { TCosmeticSurgerySpellCaster (instance size 28, VMT 557E68D4) }
  TCosmeticSurgerySpellCaster = class(TSpellCaster)
  public
    F_CosmeticSurgerySpellCaster_14: array[0..7] of Byte;
    procedure CanCast(A1: Integer); override;
    procedure Cast; override;
  end;

  { TCosmeticSurgery (instance size 68, VMT 557E69BC) }
  TCosmeticSurgery = class(TUnitSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetCombatInfo(A1: Integer; A2: Integer); override;
    procedure ValidTargetUnit(A1: Integer; A2: Integer); override;
    procedure CastSpell(A1: Integer; A2: Integer); override;
    procedure ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

procedure RegisterUnitSpells(A1: Integer; A2: Integer; A3: Integer);  { draft }
procedure UnregisterUnitSpells(A1: Integer; A2: Integer; A3: Integer);  { draft }

implementation

constructor THaste.Create(AOwner: Engine.TECustomNode);
begin end;

procedure THaste.ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure THaste.ValidTargetUnit(A1: Integer; A2: Integer);
begin end;

constructor TStoneSkin.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TStoneSkin.ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TStoneSkin.ValidTargetUnit(A1: Integer; A2: Integer);
begin end;

constructor TEnchantWeapon.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TEnchantWeapon.ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TEnchantWeapon.ValidTargetUnit(A1: Integer; A2: Integer);
begin end;

constructor TFury.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TFury.ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TFury.PlayDefaultCastEffects(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TFury.ValidTargetUnit(A1: Integer; A2: Integer);
begin end;

constructor TFreeMovement.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TFreeMovement.ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TFreeMovement.ValidTargetUnit(A1: Integer; A2: Integer);
begin end;

constructor TRemedy.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TRemedy.ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TRemedy.ValidTargetUnit(A1: Integer; A2: Integer);
begin end;

constructor THealingWater.Create(AOwner: Engine.TECustomNode);
begin end;

procedure THealingWater.ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure THealingWater.ValidTargetUnit(A1: Integer; A2: Integer);
begin end;

constructor THolyChampion.Create(AOwner: Engine.TECustomNode);
begin end;

procedure THolyChampion.ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure THolyChampion.ValidTargetUnit(A1: Integer; A2: Integer);
begin end;

constructor TUnholyChampion.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TUnholyChampion.ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TUnholyChampion.ValidTargetUnit(A1: Integer; A2: Integer);
begin end;

constructor TConcealment.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TConcealment.ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TConcealment.ValidTargetUnit(A1: Integer; A2: Integer);
begin end;

constructor TFireAura.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TFireAura.PlayDefaultCastEffects(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TFireAura.ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TFireAura.ValidTargetUnit(A1: Integer; A2: Integer);
begin end;

constructor TWaterWalking.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TWaterWalking.ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TWaterWalking.ValidTargetUnit(A1: Integer; A2: Integer);
begin end;

constructor TWindWalking.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TWindWalking.ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TWindWalking.ValidTargetUnit(A1: Integer; A2: Integer);
begin end;

constructor TLiquidForm.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TLiquidForm.ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TLiquidForm.ValidTargetUnit(A1: Integer; A2: Integer);
begin end;

procedure TLiquidForm.PlayDefaultCastEffects(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

constructor TBless.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TBless.ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TBless.ValidTargetUnit(A1: Integer; A2: Integer);
begin end;

constructor TDarkGift.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TDarkGift.ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TDarkGift.ValidTargetUnit(A1: Integer; A2: Integer);
begin end;

procedure TCosmeticSurgerySpellCaster.CanCast(A1: Integer);
begin end;

procedure TCosmeticSurgerySpellCaster.Cast;
begin end;

constructor TCosmeticSurgery.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TCosmeticSurgery.ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TCosmeticSurgery.ValidTargetUnit(A1: Integer; A2: Integer);
begin end;

procedure TCosmeticSurgery.CastSpell(A1: Integer; A2: Integer);
begin end;

procedure TCosmeticSurgery.GetCombatInfo(A1: Integer; A2: Integer);
begin end;

class function TDispelMagicSpellCA.ClassID: Integer;
begin Result := 0; end;

procedure TDispelMagicSpellCA.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TDispelMagicSpellCA.Execute(A1: TCombat; A2: Integer);
begin end;

constructor TDispelMagic.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TDispelMagic.GetDispelMana(A1: Integer);
begin end;

procedure TDispelMagic.ValidTargetParty(A1: Integer; A2: Integer);
begin end;

procedure TDispelMagic.CreateCA(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TDispelMagic.ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TDispelMagic.ValidTargetUnit(A1: Integer; A2: Integer);
begin end;

procedure TDispelMagic.GetCombatInfo(A1: Integer; A2: Integer);
begin end;

procedure RegisterUnitSpells(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure UnregisterUnitSpells(A1: Integer; A2: Integer; A3: Integer);
begin end;


initialization
finalization

end.
