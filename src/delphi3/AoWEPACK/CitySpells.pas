unit CitySpells;

{ Draft declarations of CitySpells, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TCityTargetSpellTE = class;
  TCityTargetSpell = class;
  TTownGateTE = class;
  TTownGate = class;
  TCityEnchantmentSpellTE = class;
  TCityEnchantmentSpell = class;
  TFountainOfLife = class;
  TGoldRush = class;
  TAntiMagicShell = class;
  TWarmonger = class;
  TTownQuake = class;
  TAnarchy = class;
  TAnimateRuins = class;

  TCityTargetMode = set of (ctmOwn, ctmEnemy, ctmSkipSource, ctmRazed); { ot=1 }
  TCityEnchantmentCastSpellSituation = set of (ccsLeaderInCity, ccs4HexCity, ccs3HexCity); { ot=1 }

  { TCityTargetSpellTE (instance size 40, VMT 557AF390) }
  TCityTargetSpellTE = class(TSpellTE)
  public
    F_CityTargetSpellTE_20: Integer;
    F_CityTargetSpellTE_24: Byte;
    F_CityTargetSpellTE_25: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Validate(A1: Integer); override;
    procedure SetLocation(A1: Byte; A2: Byte; A3: Integer);  { draft }
    procedure GetSelectedCity;  { draft }
  end;

  { TCityTargetSpell (instance size 60, VMT 557AF4C8) }
  TCityTargetSpell = class(TSpell)
  public
    F_CityTargetSpell_34: Integer;
    F_CityTargetSpell_38: Byte;
    F_CityTargetSpell_39: array[0..2] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure OnTargetSelectionChange(A1: Integer; A2: Integer); virtual;  { +09C draft }
    procedure PlayDefaultCityEffects(A1: Integer; A2: Integer); virtual;  { +0A0 draft }
    procedure SetupTargetSelection(A1: Integer; A2: Integer); virtual;  { +0A4 draft }
    procedure TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +0A8 draft }
    procedure ValidTargetCity(A1: Integer; A2: Integer); virtual;  { +0AC draft }
    procedure CreateTE; virtual;  { +0B0 draft }
    procedure SetupTE(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); virtual;  { +0B4 draft }
    procedure ValidateTarget(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
  end;

  { TTownGateTE (instance size 48, VMT 557AF604) }
  TTownGateTE = class(TCityTargetSpellTE)
  public
    F_TownGateTE_28: Integer;
    F_TownGateTE_2C: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Validate(A1: Integer); override;
  end;

  { TTownGate (instance size 60, VMT 557AF6D4) }
  TTownGate = class(TCityTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ExecuteTE(A1: Integer; A2: Integer; A3: Integer); override;
    procedure CanActivate(A1: Integer; A2: Integer); override;
    procedure SetupTargetSelection(A1: Integer; A2: Integer); override;
    procedure CreateTE; override;
    procedure SetupTE(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
    procedure ValidTeleportLocation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
  end;

  { TCityEnchantmentSpellTE (instance size 40, VMT 557AF800) }
  TCityEnchantmentSpellTE = class(TCityTargetSpellTE)
  public
    class function ClassID: Integer; override;
  end;

  { TCityEnchantmentSpell (instance size 80, VMT 557AF958) }
  TCityEnchantmentSpell = class(TCityTargetSpell)
  public
    F_CityEnchantmentSpell_3C: Byte;
    F_CityEnchantmentSpell_3D: array[0..2] of Byte;
    F_CityEnchantmentSpell_40: Integer;
    F_CityEnchantmentSpell_44: Integer;
    F_CityEnchantmentSpell_48: Integer;
    F_CityEnchantmentSpell_4C: Byte;
    F_CityEnchantmentSpell_4D: array[0..2] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ExecuteTE(A1: Integer; A2: Integer; A3: Integer); override;
    procedure AIPrefetchCastSpellActions(A1: Integer; A2: Integer); override;
    procedure AIExecuteCastSpellAction(A1: Integer); override;
    procedure ValidTargetCity(A1: Integer; A2: Integer); override;
    procedure CreateTE; override;
    procedure SetupTE(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
  end;

  { TFountainOfLife (instance size 80, VMT 557AFA9C) }
  TFountainOfLife = class(TCityEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ExecuteTE(A1: Integer; A2: Integer; A3: Integer); override;
    procedure ShowFountain(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
  end;

  { TGoldRush (instance size 80, VMT 557AFBD0) }
  TGoldRush = class(TCityEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TAntiMagicShell (instance size 80, VMT 557AFCFC) }
  TAntiMagicShell = class(TCityEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure PlayDefaultCityEffects(A1: Integer; A2: Integer); override;
  end;

  { TWarmonger (instance size 80, VMT 557AFE30) }
  TWarmonger = class(TCityEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TTownQuake (instance size 60, VMT 557AFF5C) }
  TTownQuake = class(TCityTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ExecuteTE(A1: Integer; A2: Integer; A3: Integer); override;
    procedure ValidTargetCity(A1: Integer; A2: Integer); override;
    procedure TriggerArmyDamage(A1: Integer; A2: Integer);  { draft }
  end;

  { TAnarchy (instance size 60, VMT 557B0088) }
  TAnarchy = class(TCityTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ExecuteTE(A1: Integer; A2: Integer; A3: Integer); override;
    procedure ValidTargetCity(A1: Integer; A2: Integer); override;
    procedure ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
  end;

  { TAnimateRuins (instance size 60, VMT 557B01B4) }
  TAnimateRuins = class(TCityTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ExecuteTE(A1: Integer; A2: Integer; A3: Integer); override;
    procedure ValidTargetCity(A1: Integer; A2: Integer); override;
    procedure ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
  end;

procedure RegisterCitySpells(A1: Integer);  { draft }
procedure UnregisterCitySpells(A1: Integer);  { draft }

implementation

class function TCityTargetSpellTE.ClassID: Integer;
begin Result := 0; end;

procedure TCityTargetSpellTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TCityTargetSpellTE.SetLocation(A1: Byte; A2: Byte; A3: Integer);
begin end;

procedure TCityTargetSpellTE.Validate(A1: Integer);
begin end;

procedure TCityTargetSpellTE.GetSelectedCity;
begin end;

constructor TCityTargetSpell.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TCityTargetSpell.PlayDefaultCityEffects(A1: Integer; A2: Integer);
begin end;

procedure TCityTargetSpell.ValidTargetCity(A1: Integer; A2: Integer);
begin end;

procedure TCityTargetSpell.ValidateTarget(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TCityTargetSpell.OnTargetSelectionChange(A1: Integer; A2: Integer);
begin end;

procedure TCityTargetSpell.SetupTargetSelection(A1: Integer; A2: Integer);
begin end;

procedure TCityTargetSpell.CreateTE;
begin end;

procedure TCityTargetSpell.SetupTE(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TCityTargetSpell.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TCityTargetSpell.Activate(A1: Integer; A2: Integer);
begin end;

destructor TTownGateTE.Destroy;
begin end;

class function TTownGateTE.ClassID: Integer;
begin Result := 0; end;

procedure TTownGateTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TTownGateTE.Validate(A1: Integer);
begin end;

constructor TTownGate.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TTownGate.ValidTeleportLocation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TTownGate.CreateTE;
begin end;

procedure TTownGate.SetupTE(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TTownGate.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TTownGate.CanActivate(A1: Integer; A2: Integer);
begin end;

procedure TTownGate.SetupTargetSelection(A1: Integer; A2: Integer);
begin end;

class function TCityEnchantmentSpellTE.ClassID: Integer;
begin Result := 0; end;

constructor TCityEnchantmentSpell.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TCityEnchantmentSpell.CreateTE;
begin end;

procedure TCityEnchantmentSpell.SetupTE(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TCityEnchantmentSpell.ValidTargetCity(A1: Integer; A2: Integer);
begin end;

procedure TCityEnchantmentSpell.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TCityEnchantmentSpell.AIPrefetchCastSpellActions(A1: Integer; A2: Integer);
begin end;

procedure TCityEnchantmentSpell.AIExecuteCastSpellAction(A1: Integer);
begin end;

constructor TFountainOfLife.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TFountainOfLife.ShowFountain(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TFountainOfLife.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
begin end;

constructor TGoldRush.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TAntiMagicShell.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TAntiMagicShell.PlayDefaultCityEffects(A1: Integer; A2: Integer);
begin end;

constructor TWarmonger.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TTownQuake.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TTownQuake.TriggerArmyDamage(A1: Integer; A2: Integer);
begin end;

procedure TTownQuake.ValidTargetCity(A1: Integer; A2: Integer);
begin end;

procedure TTownQuake.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
begin end;

constructor TAnarchy.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TAnarchy.ValidTargetCity(A1: Integer; A2: Integer);
begin end;

procedure TAnarchy.ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAnarchy.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
begin end;

constructor TAnimateRuins.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TAnimateRuins.ValidTargetCity(A1: Integer; A2: Integer);
begin end;

procedure TAnimateRuins.ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAnimateRuins.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure RegisterCitySpells(A1: Integer);
begin end;

procedure UnregisterCitySpells(A1: Integer);
begin end;


initialization
finalization

end.
