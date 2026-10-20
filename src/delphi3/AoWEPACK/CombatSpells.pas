unit CombatSpells;

{ Draft declarations of CombatSpells, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TCombatSpellCA = class;
  TExclusiveCombatSpellCA = class;
  TMultiTargetCombatSpellCA = class;
  TCombatSpell = class;
  TSolarFlare = class;
  TTurnUndeadSpellCA = class;
  TTurnUndead = class;
  TFastCombatHighPrayerCA = class;
  TTacticalCombatHighPrayerCA = class;
  THighPrayer = class;
  TDeathRay = class;
  TDiseaseCloud = class;
  TMindDecayCA = class;
  TMindDecay = class;
  TChainLightning = class;
  TColdBreath = class;
  TSlowCA = class;
  TSlow = class;
  TEntangleSpellCA = class;
  TEntangle = class;
  TTremors = class;
  TCallFlames = class;
  TFireBreath = class;
  TSwarm = class;
  TGreatHail = class;
  TFireBall = class;
  TGeyser = class;
  TIceShards = class;
  TFrostBeams = class;
  TVaporize = class;
  TFlamingArrow = class;
  TStoning = class;
  TOoze = class;
  TSacredWrath = class;
  TFastCombatTerrorCA = class;
  TTacticalCombatTerrorCA = class;
  TTerror = class;
  TWindsOfFury = class;
  TShockwave = class;
  TSacrificialFlame = class;
  TRecallSpiritCA = class;
  TRecallSpirit = class;
  TAnimateDeadCA = class;
  TAnimateDead = class;


  { TCombatSpellCA (instance size 32, VMT 557F3CC8) }
  TCombatSpellCA = class(TDamageCA)
  public
    F_CombatSpellCA_18: Integer;
    F_CombatSpellCA_1C: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure ShowFieldObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
  end;

  { TExclusiveCombatSpellCA (instance size 28, VMT 557F3DB8) }
  TExclusiveCombatSpellCA = class(TCombatAction)
  public
    F_ExclusiveCombatSpellCA_0C: Byte;
    F_ExclusiveCombatSpellCA_0D: Byte;
    F_ExclusiveCombatSpellCA_0E: array[0..1] of Byte;
    F_ExclusiveCombatSpellCA_10: Integer;
    F_ExclusiveCombatSpellCA_14: Byte;
    F_ExclusiveCombatSpellCA_15: array[0..2] of Byte;
    F_ExclusiveCombatSpellCA_18: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure ShowFieldObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
  end;

  { TMultiTargetCombatSpellCA (instance size 32, VMT 557F3EAC) }
  TMultiTargetCombatSpellCA = class(TCombatAction)
  public
    F_MultiTargetCombatSpellCA_0C: Byte;
    F_MultiTargetCombatSpellCA_0D: array[0..2] of Byte;
    F_MultiTargetCombatSpellCA_10: Integer;
    F_MultiTargetCombatSpellCA_14: Integer;
    F_MultiTargetCombatSpellCA_18: Byte;
    F_MultiTargetCombatSpellCA_19: array[0..2] of Byte;
    F_MultiTargetCombatSpellCA_1C: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure ShowFieldObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure ShowFightingObjects(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
  end;

  { TCombatSpell (instance size 64, VMT 557F3FA4) }
  TCombatSpell = class(TSpell)
  public
    F_CombatSpell_34: Integer;
    F_CombatSpell_38: Integer;
    F_CombatSpell_3C: Byte;
    F_CombatSpell_3D: array[0..2] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateCA(A1: Integer; A2: Integer; A3: Integer); override;
    procedure GetCombatInfo(A1: Integer; A2: Integer); override;
    procedure GetCombatDamageValue(A1: Integer; A2: Integer); override;
    procedure GetCombatDamageValueEx(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcPrefetchCombatCommands(A1: Integer); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

  { TSolarFlare (instance size 64, VMT 557F40BC) }
  TSolarFlare = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TTurnUndeadSpellCA (instance size 32, VMT 557F41D0) }
  TTurnUndeadSpellCA = class(TCombatSpellCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
  end;

  { TTurnUndead (instance size 64, VMT 557F42C8) }
  TTurnUndead = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateCA(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

  { TFastCombatHighPrayerCA (instance size 32, VMT 557F43DC) }
  TFastCombatHighPrayerCA = class(TMultiTargetCombatSpellCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Generate(A1: Integer);  { draft }
  end;

  { TTacticalCombatHighPrayerCA (instance size 28, VMT 557F44D0) }
  TTacticalCombatHighPrayerCA = class(TExclusiveCombatSpellCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
  end;

  { THighPrayer (instance size 64, VMT 557F45CC) }
  THighPrayer = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateCA(A1: Integer; A2: Integer; A3: Integer); override;
    procedure tcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcPrefetchCombatCommands(A1: Integer); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

  { TDeathRay (instance size 64, VMT 557F46E0) }
  TDeathRay = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TDiseaseCloud (instance size 64, VMT 557F47F0) }
  TDiseaseCloud = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TMindDecayCA (instance size 28, VMT 557F4908) }
  TMindDecayCA = class(TExclusiveCombatSpellCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
  end;

  { TMindDecay (instance size 64, VMT 557F49E8) }
  TMindDecay = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateCA(A1: Integer; A2: Integer; A3: Integer); override;
  end;

  { TChainLightning (instance size 64, VMT 557F4AFC) }
  TChainLightning = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TColdBreath (instance size 64, VMT 557F4C18) }
  TColdBreath = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TSlowCA (instance size 28, VMT 557F4D2C) }
  TSlowCA = class(TExclusiveCombatSpellCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
  end;

  { TSlow (instance size 64, VMT 557F4E00) }
  TSlow = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateCA(A1: Integer; A2: Integer; A3: Integer); override;
    procedure GetCombatDamageValueEx(A1: Integer; A2: Integer; A3: Integer); override;
  end;

  { TEntangleSpellCA (instance size 28, VMT 557F4F08) }
  TEntangleSpellCA = class(TExclusiveCombatSpellCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
  end;

  { TEntangle (instance size 64, VMT 557F4FF0) }
  TEntangle = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateCA(A1: Integer; A2: Integer; A3: Integer); override;
    procedure GetCombatDamageValueEx(A1: Integer; A2: Integer; A3: Integer); override;
  end;

  { TTremors (instance size 64, VMT 557F5100) }
  TTremors = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TCallFlames (instance size 64, VMT 557F5210) }
  TCallFlames = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TFireBreath (instance size 64, VMT 557F5324) }
  TFireBreath = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TSwarm (instance size 64, VMT 557F5438) }
  TSwarm = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TGreatHail (instance size 64, VMT 557F5544) }
  TGreatHail = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TFireBall (instance size 64, VMT 557F5658) }
  TFireBall = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TGeyser (instance size 64, VMT 557F5768) }
  TGeyser = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateCA(A1: Integer; A2: Integer; A3: Integer); override;
  end;

  { TIceShards (instance size 64, VMT 557F5874) }
  TIceShards = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TFrostBeams (instance size 64, VMT 557F5988) }
  TFrostBeams = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TVaporize (instance size 64, VMT 557F5A9C) }
  TVaporize = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TFlamingArrow (instance size 64, VMT 557F5BAC) }
  TFlamingArrow = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TStoning (instance size 64, VMT 557F5CC4) }
  TStoning = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TOoze (instance size 64, VMT 557F5DD4) }
  TOoze = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetCombatDamageValueEx(A1: Integer; A2: Integer; A3: Integer); override;
  end;

  { TSacredWrath (instance size 64, VMT 557F5EDC) }
  TSacredWrath = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TFastCombatTerrorCA (instance size 32, VMT 557F5FF4) }
  TFastCombatTerrorCA = class(TMultiTargetCombatSpellCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Generate(A1: Integer);  { draft }
  end;

  { TTacticalCombatTerrorCA (instance size 24, VMT 557F60E0) }
  TTacticalCombatTerrorCA = class(TCombatAction)
  public
    F_TacticalCombatTerrorCA_0C: Byte;
    F_TacticalCombatTerrorCA_0D: Byte;
    F_TacticalCombatTerrorCA_0E: array[0..1] of Byte;
    F_TacticalCombatTerrorCA_10: Integer;
    F_TacticalCombatTerrorCA_14: Byte;
    F_TacticalCombatTerrorCA_15: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
    procedure Generate(A1: Integer; A2: Integer);  { draft }
  end;

  { TTerror (instance size 64, VMT 557F61D4) }
  TTerror = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateCA(A1: Integer; A2: Integer; A3: Integer); override;
    procedure tcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcPrefetchCombatCommands(A1: Integer); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

  { TWindsOfFury (instance size 64, VMT 557F62E0) }
  TWindsOfFury = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateCA(A1: Integer; A2: Integer; A3: Integer); override;
  end;

  { TShockwave (instance size 64, VMT 557F63F8) }
  TShockwave = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TSacrificialFlame (instance size 64, VMT 557F650C) }
  TSacrificialFlame = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TRecallSpiritCA (instance size 28, VMT 557F662C) }
  TRecallSpiritCA = class(TExclusiveCombatSpellCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
  end;

  { TRecallSpirit (instance size 64, VMT 557F6710) }
  TRecallSpirit = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateCA(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

  { TAnimateDeadCA (instance size 28, VMT 557F6828) }
  TAnimateDeadCA = class(TExclusiveCombatSpellCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
  end;

  { TAnimateDead (instance size 64, VMT 557F690C) }
  TAnimateDead = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateCA(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

procedure RegisterCombatSpells(A1: Integer);  { draft }
procedure UnregisterCombatSpells(A1: Integer);  { draft }

implementation

class function TCombatSpellCA.ClassID: Integer;
begin Result := 0; end;

procedure TCombatSpellCA.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TCombatSpellCA.Execute(A1: Integer; A2: Integer);
begin end;

procedure TCombatSpellCA.Play(A1: Integer);
begin end;

procedure TCombatSpellCA.ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

procedure TCombatSpellCA.ShowFieldObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

procedure TExclusiveCombatSpellCA.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TExclusiveCombatSpellCA.Execute(A1: Integer; A2: Integer);
begin end;

procedure TExclusiveCombatSpellCA.Play(A1: Integer);
begin end;

procedure TExclusiveCombatSpellCA.ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

procedure TExclusiveCombatSpellCA.ShowFieldObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

constructor TMultiTargetCombatSpellCA.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TMultiTargetCombatSpellCA.Destroy;
begin end;

procedure TMultiTargetCombatSpellCA.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TMultiTargetCombatSpellCA.Execute(A1: Integer; A2: Integer);
begin end;

procedure TMultiTargetCombatSpellCA.Play(A1: Integer);
begin end;

procedure TMultiTargetCombatSpellCA.ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

procedure TMultiTargetCombatSpellCA.ShowFieldObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

procedure TMultiTargetCombatSpellCA.ShowFightingObjects(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

constructor TCombatSpell.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TCombatSpell.GetCombatInfo(A1: Integer; A2: Integer);
begin end;

procedure TCombatSpell.GetCombatDamageValue(A1: Integer; A2: Integer);
begin end;

procedure TCombatSpell.CreateCA(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TCombatSpell.GetCombatDamageValueEx(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TCombatSpell.fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TCombatSpell.fcPrefetchCombatCommands(A1: Integer);
begin end;

procedure TCombatSpell.fcExecuteCombatCommand(A1: Integer; A2: Integer);
begin end;

constructor TSolarFlare.Create(AOwner: Engine.TECustomNode);
begin end;

class function TTurnUndeadSpellCA.ClassID: Integer;
begin Result := 0; end;

procedure TTurnUndeadSpellCA.Execute(A1: Integer; A2: Integer);
begin end;

constructor TTurnUndead.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TTurnUndead.CreateCA(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TTurnUndead.fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

class function TFastCombatHighPrayerCA.ClassID: Integer;
begin Result := 0; end;

procedure TFastCombatHighPrayerCA.Execute(A1: Integer; A2: Integer);
begin end;

procedure TFastCombatHighPrayerCA.Generate(A1: Integer);
begin end;

class function TTacticalCombatHighPrayerCA.ClassID: Integer;
begin Result := 0; end;

procedure TTacticalCombatHighPrayerCA.Execute(A1: Integer; A2: Integer);
begin end;

constructor THighPrayer.Create(AOwner: Engine.TECustomNode);
begin end;

procedure THighPrayer.CreateCA(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure THighPrayer.fcPrefetchCombatCommands(A1: Integer);
begin end;

procedure THighPrayer.fcExecuteCombatCommand(A1: Integer; A2: Integer);
begin end;

procedure THighPrayer.fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure THighPrayer.tcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer);
begin end;

constructor TDeathRay.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TDiseaseCloud.Create(AOwner: Engine.TECustomNode);
begin end;

class function TMindDecayCA.ClassID: Integer;
begin Result := 0; end;

procedure TMindDecayCA.Execute(A1: Integer; A2: Integer);
begin end;

constructor TMindDecay.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TMindDecay.CreateCA(A1: Integer; A2: Integer; A3: Integer);
begin end;

constructor TChainLightning.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TColdBreath.Create(AOwner: Engine.TECustomNode);
begin end;

class function TSlowCA.ClassID: Integer;
begin Result := 0; end;

procedure TSlowCA.Execute(A1: Integer; A2: Integer);
begin end;

constructor TSlow.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TSlow.GetCombatDamageValueEx(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TSlow.CreateCA(A1: Integer; A2: Integer; A3: Integer);
begin end;

class function TEntangleSpellCA.ClassID: Integer;
begin Result := 0; end;

procedure TEntangleSpellCA.Execute(A1: Integer; A2: Integer);
begin end;

constructor TEntangle.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TEntangle.CreateCA(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TEntangle.GetCombatDamageValueEx(A1: Integer; A2: Integer; A3: Integer);
begin end;

constructor TTremors.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TCallFlames.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TFireBreath.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TSwarm.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TGreatHail.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TFireBall.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TGeyser.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TGeyser.CreateCA(A1: Integer; A2: Integer; A3: Integer);
begin end;

constructor TIceShards.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TFrostBeams.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TVaporize.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TStoning.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TFlamingArrow.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TOoze.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TOoze.GetCombatDamageValueEx(A1: Integer; A2: Integer; A3: Integer);
begin end;

constructor TSacredWrath.Create(AOwner: Engine.TECustomNode);
begin end;

class function TFastCombatTerrorCA.ClassID: Integer;
begin Result := 0; end;

procedure TFastCombatTerrorCA.Execute(A1: Integer; A2: Integer);
begin end;

procedure TFastCombatTerrorCA.Generate(A1: Integer);
begin end;

class function TTacticalCombatTerrorCA.ClassID: Integer;
begin Result := 0; end;

procedure TTacticalCombatTerrorCA.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TTacticalCombatTerrorCA.Execute(A1: Integer; A2: Integer);
begin end;

procedure TTacticalCombatTerrorCA.Play(A1: Integer);
begin end;

procedure TTacticalCombatTerrorCA.Generate(A1: Integer; A2: Integer);
begin end;

constructor TTerror.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TTerror.CreateCA(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TTerror.fcPrefetchCombatCommands(A1: Integer);
begin end;

procedure TTerror.fcExecuteCombatCommand(A1: Integer; A2: Integer);
begin end;

procedure TTerror.fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TTerror.tcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer);
begin end;

constructor TWindsOfFury.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TWindsOfFury.CreateCA(A1: Integer; A2: Integer; A3: Integer);
begin end;

constructor TShockwave.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TSacrificialFlame.Create(AOwner: Engine.TECustomNode);
begin end;

class function TRecallSpiritCA.ClassID: Integer;
begin Result := 0; end;

procedure TRecallSpiritCA.Execute(A1: Integer; A2: Integer);
begin end;

constructor TRecallSpirit.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TRecallSpirit.fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TRecallSpirit.CreateCA(A1: Integer; A2: Integer; A3: Integer);
begin end;

class function TAnimateDeadCA.ClassID: Integer;
begin Result := 0; end;

procedure TAnimateDeadCA.Execute(A1: Integer; A2: Integer);
begin end;

constructor TAnimateDead.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TAnimateDead.fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAnimateDead.CreateCA(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure RegisterCombatSpells(A1: Integer);
begin end;

procedure UnregisterCombatSpells(A1: Integer);
begin end;


initialization
finalization

end.
