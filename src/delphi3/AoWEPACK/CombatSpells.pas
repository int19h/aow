unit CombatSpells;

{ Draft declarations of CombatSpells, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  All class bodies and registration routines are recovered below. }

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


  { TCombatSpellCA (instance size 32, VMT 557F3CC8):
    $18 spell ID, $1C casting mana; source and target IDs inherited at $0D/$0E. }
  TCombatSpellCA = class(TDamageCA)
  public
    FSpellID: Integer;
    FManaCost: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
    procedure ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc); override;
    procedure ShowFieldObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc); override;
  end;

  { TExclusiveCombatSpellCA (instance size 28, VMT 557F3DB8):
    $0C source ID, $0D target ID, $10 casting mana, $14 success, $18 spell ID. }
  TExclusiveCombatSpellCA = class(TCombatAction)
  public
    FSourceID: Byte;
    FTargetID: Byte;
    F_ExclusiveCombatSpellCA_0E: array[0..1] of Byte;
    FManaCost: Integer;
    FSucceeded: Boolean;
    F_ExclusiveCombatSpellCA_15: array[0..2] of Byte;
    FSpellID: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
    procedure ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc); override;
    procedure ShowFieldObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc); override;
  end;

  { TMultiTargetCombatSpellCA (instance size 32, VMT 557F3EAC):
    $0C source ID, $10 target byte list, $14 casting mana, $18 success, $1C spell ID. }
  TMultiTargetCombatSpellCA = class(TCombatAction)
  public
    FSourceID: Byte;
    F_MultiTargetCombatSpellCA_0D: array[0..2] of Byte;
    FTargetIDs: TByteList;
    FManaCost: Integer;
    FSucceeded: Boolean;
    F_MultiTargetCombatSpellCA_19: array[0..2] of Byte;
    FSpellID: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
    procedure ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc); override;
    procedure ShowFieldObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc); override;
    procedure ShowFightingObjects(A1: TCombatViewer; A2: Integer; A3: Integer; A4: Integer; const A5: TSurfaceDesc); override;
  end;

  { TCombatSpell (instance size 64, VMT 557F3FA4):
    $34 combat statistics (attack, damage, types, repeats, range, radius, targets);
    $3C damage mode, $3D padding. }
  TCombatSpell = class(TSpell)
  public
    FCombatInfo: TSpellCombatInfo; { $34 }
    FDamageMode: Byte; { $3C }
    F_CombatSpell_3D: array[0..2] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction; override;
    procedure GetCombatInfo(Source: TAbstractUnit; var Info: TSpellCombatInfo); override;
    function GetCombatDamageValue(A1, A2: TCombatObject): Integer; override;
    procedure GetCombatDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues); override;
    procedure fcPrefetchCombatCommands(A1: TFastCombatCommandList); override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues); override;
  end;

  { TSolarFlare (instance size 64, VMT 557F40BC):
    inherited $34 combat statistics, $3C damage mode. }
  TSolarFlare = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TTurnUndeadSpellCA (instance size 32, VMT 557F41D0) }
  TTurnUndeadSpellCA = class(TCombatSpellCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
  end;

  { TTurnUndead (instance size 64, VMT 557F42C8):
    inherited $34 combat statistics, $3C damage mode. }
  TTurnUndead = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction; override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues); override;
  end;

  { TFastCombatHighPrayerCA (instance size 32, VMT 557F43DC) }
  TFastCombatHighPrayerCA = class(TMultiTargetCombatSpellCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    procedure Generate(A1: TCombatObject);
  end;

  { TTacticalCombatHighPrayerCA (instance size 28, VMT 557F44D0) }
  TTacticalCombatHighPrayerCA = class(TExclusiveCombatSpellCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
  end;

  { THighPrayer (instance size 64, VMT 557F45CC):
    inherited $34 combat statistics, $3C damage mode. }
  THighPrayer = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction; override;
    procedure tcGetDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues); override;
    procedure fcPrefetchCombatCommands(A1: TFastCombatCommandList); override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues); override;
  end;

  { TDeathRay (instance size 64, VMT 557F46E0):
    inherited $34 combat statistics, $3C damage mode. }
  TDeathRay = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TDiseaseCloud (instance size 64, VMT 557F47F0):
    inherited $34 combat statistics, $3C damage mode. }
  TDiseaseCloud = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TMindDecayCA (instance size 28, VMT 557F4908) }
  TMindDecayCA = class(TExclusiveCombatSpellCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
  end;

  { TMindDecay (instance size 64, VMT 557F49E8):
    inherited $34 combat statistics, $3C damage mode. }
  TMindDecay = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction; override;
  end;

  { TChainLightning (instance size 64, VMT 557F4AFC):
    inherited $34 combat statistics, $3C damage mode. }
  TChainLightning = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TColdBreath (instance size 64, VMT 557F4C18):
    inherited $34 combat statistics, $3C damage mode. }
  TColdBreath = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TSlowCA (instance size 28, VMT 557F4D2C) }
  TSlowCA = class(TExclusiveCombatSpellCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
  end;

  { TSlow (instance size 64, VMT 557F4E00):
    inherited $34 combat statistics, $3C damage mode. }
  TSlow = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction; override;
    procedure GetCombatDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues); override;
  end;

  { TEntangleSpellCA (instance size 28, VMT 557F4F08) }
  TEntangleSpellCA = class(TExclusiveCombatSpellCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
  end;

  { TEntangle (instance size 64, VMT 557F4FF0):
    inherited $34 combat statistics, $3C damage mode. }
  TEntangle = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction; override;
    procedure GetCombatDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues); override;
  end;

  { TTremors (instance size 64, VMT 557F5100):
    inherited $34 combat statistics, $3C damage mode. }
  TTremors = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TCallFlames (instance size 64, VMT 557F5210):
    inherited $34 combat statistics, $3C damage mode. }
  TCallFlames = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TFireBreath (instance size 64, VMT 557F5324):
    inherited $34 combat statistics, $3C damage mode. }
  TFireBreath = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TSwarm (instance size 64, VMT 557F5438):
    inherited $34 combat statistics, $3C damage mode. }
  TSwarm = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TGreatHail (instance size 64, VMT 557F5544):
    inherited $34 combat statistics, $3C damage mode. }
  TGreatHail = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TFireBall (instance size 64, VMT 557F5658):
    inherited $34 combat statistics, $3C damage mode. }
  TFireBall = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TGeyser (instance size 64, VMT 557F5768):
    inherited $34 combat statistics, $3C damage mode. }
  TGeyser = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction; override;
  end;

  { TIceShards (instance size 64, VMT 557F5874):
    inherited $34 combat statistics, $3C damage mode. }
  TIceShards = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TFrostBeams (instance size 64, VMT 557F5988):
    inherited $34 combat statistics, $3C damage mode. }
  TFrostBeams = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TVaporize (instance size 64, VMT 557F5A9C):
    inherited $34 combat statistics, $3C damage mode. }
  TVaporize = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TFlamingArrow (instance size 64, VMT 557F5BAC):
    inherited $34 combat statistics, $3C damage mode. }
  TFlamingArrow = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TStoning (instance size 64, VMT 557F5CC4):
    inherited $34 combat statistics, $3C damage mode. }
  TStoning = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TOoze (instance size 64, VMT 557F5DD4):
    inherited $34 combat statistics, $3C damage mode. }
  TOoze = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetCombatDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues); override;
  end;

  { TSacredWrath (instance size 64, VMT 557F5EDC):
    inherited $34 combat statistics, $3C damage mode. }
  TSacredWrath = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TFastCombatTerrorCA (instance size 32, VMT 557F5FF4) }
  TFastCombatTerrorCA = class(TMultiTargetCombatSpellCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    procedure Generate(A1: TCombatObject);
  end;

  { TTacticalCombatTerrorCA (instance size 24, VMT 557F60E0):
    $0C source ID, $0D target ID, $10 casting mana, $14 success. }
  TTacticalCombatTerrorCA = class(TCombatAction)
  public
    FSourceID: Byte; { $0C }
    FTargetID: Byte; { $0D }
    F_TacticalCombatTerrorCA_0E: array[0..1] of Byte;
    FManaCost: Integer; { $10 }
    FSucceeded: Boolean; { $14 }
    F_TacticalCombatTerrorCA_15: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
    procedure Generate(A1, A2: TCombatObject);
  end;

  { TTerror (instance size 64, VMT 557F61D4):
    inherited $34 combat statistics, $3C damage mode. }
  TTerror = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction; override;
    procedure tcGetDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues); override;
    procedure fcPrefetchCombatCommands(A1: TFastCombatCommandList); override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues); override;
  end;

  { TWindsOfFury (instance size 64, VMT 557F62E0): inherited $10 spell ID, $34 combat statistics, $3C damage mode. }
  TWindsOfFury = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction; override;
  end;

  { TShockwave (instance size 64, VMT 557F63F8): inherited $10 spell ID, $34 combat statistics, $3C damage mode. }
  TShockwave = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TSacrificialFlame (instance size 64, VMT 557F650C): inherited $10 spell ID, $34 combat statistics, $3C damage mode. }
  TSacrificialFlame = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TRecallSpiritCA (instance size 28, VMT 557F662C): inherited $0C source ID, $0D target ID, $10 mana, $14 success, $18 spell ID. }
  TRecallSpiritCA = class(TExclusiveCombatSpellCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
  end;

  { TRecallSpirit (instance size 64, VMT 557F6710): inherited $10 spell ID, $34 combat statistics, $3C damage mode. }
  TRecallSpirit = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction; override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues); override;
  end;

  { TAnimateDeadCA (instance size 28, VMT 557F6828): inherited $0C source ID, $0D target ID, $10 mana, $14 success, $18 spell ID. }
  TAnimateDeadCA = class(TExclusiveCombatSpellCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
  end;

  { TAnimateDead (instance size 64, VMT 557F690C): inherited $10 spell ID, $34 combat statistics, $3C damage mode. }
  TAnimateDead = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction; override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues); override;
  end;

procedure RegisterCombatSpells(Engine: TAoWEngine);
procedure UnregisterCombatSpells(Engine: TAoWEngine);

implementation


class function TCombatSpellCA.ClassID: Integer;
begin
  Result := $202C2;
end;

procedure TCombatSpellCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FSpellID, 30);
  Stream.rwInteger(FManaCost, 31);
end;

procedure TCombatSpellCA.Execute(A1: TCombat);
var
  Source: TCombatObject;
begin
  inherited Execute(A1);
  if (FManaCost <> 0) and (cExecuting in A1.FStatus) then
  begin
    Source := A1.FCombatData.FindID(FSourceID);
    AoWHSSet.FSpellControl.GetSpell(FSpellID).CombatCastingDone(Source, FManaCost);
  end;
end;

function TCombatSpellCA.Play(A1: TCombatViewer): Boolean;
begin
  if A1.FTime = 0 then
    AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastSounds.Play(0);
  if A1.FDelay = A1.FTime then Execute(A1.FCombat);
  Result := A1.FDelay * 2 > A1.FTime;
end;

procedure TCombatSpellCA.ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc);
begin
  inherited ShowObject(A1, A2, A3, A4, A5, A6, A7);
  if A2.FID = FSourceID then
    AoWEngine.FCombatFont.SetTextCentered(A5 + 32, A6 + 32 + 8,
      AoWHSSet.FSpellControl.GetSpell(FSpellID).FSpellName, A7)
  else if A2.FID = FTargetID then
    AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastImages.Show(11,
      A5 + 32, A6 + 32, A1.FTime, A7);
end;

procedure TCombatSpellCA.ShowFieldObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc);
begin
  { Original calls ShowObject here, bypassing inherited field markers. }
  inherited ShowObject(A1, A2, A3, A4, A5, A6, A7);
  if A2.FID = FSourceID then
    AoWEngine.FCombatFont.SetTextCentered(A5 + 32, A6 + 32 + 8,
      AoWHSSet.FSpellControl.GetSpell(FSpellID).FSpellName, A7)
  else if A2.FID = FTargetID then
    AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastImages.Show(11,
      A5 + 32, A6 + 32, A1.FTime, A7);
end;

procedure TExclusiveCombatSpellCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(FSourceID, 20);
  Stream.rwByte(FTargetID, 21);
  Stream.rwInteger(FManaCost, 22);
  Stream.rwBool(FSucceeded, 23);
  Stream.rwInteger(FSpellID, 24);
end;

procedure TExclusiveCombatSpellCA.Execute(A1: TCombat);
var
  Source: TCombatObject;
begin
  with A1 do
  if (FManaCost <> 0) and (cExecuting in FStatus) then
  begin
    Source := FCombatData.FindID(FSourceID);
    AoWHSSet.FSpellControl.GetSpell(FSpellID).CombatCastingDone(Source, FManaCost);
  end;
end;

function TExclusiveCombatSpellCA.Play(A1: TCombatViewer): Boolean;
begin
  if A1.FTime = 0 then
    AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastSounds.Play(0);
  if A1.FDelay = A1.FTime then Execute(A1.FCombat);
  Result := A1.FDelay * 3 > A1.FTime;
end;

procedure TExclusiveCombatSpellCA.ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc);
begin
  if A2.FID = FSourceID then
    A2.ShowAttackAnimation(A1.FTime, A4, A5, A6, A7)
  else inherited ShowObject(A1, A2, A3, A4, A5, A6, A7);
  if A2.FID = FSourceID then
    AoWEngine.FCombatFont.SetTextCentered(A5 + 32, A6 + 32 + 8,
      AoWHSSet.FSpellControl.GetSpell(FSpellID).FSpellName, A7)
  else if A2.FID = FTargetID then
    AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastImages.Show(11,
      A5 + 32, A6 + 32, A1.FTime, A7);
end;

procedure TExclusiveCombatSpellCA.ShowFieldObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc);
begin
  { Original calls ShowObject here, bypassing inherited field markers. }
  inherited ShowObject(A1, A2, A3, A4, A5, A6, A7);
  if A2.FID = FSourceID then
    AoWEngine.FCombatFont.SetTextCentered(A5 + 32, A6 + 32 + 8,
      AoWHSSet.FSpellControl.GetSpell(FSpellID).FSpellName, A7)
  else if A2.FID = FTargetID then
    AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastImages.Show(11,
      A5 + 32, A6 + 32, A1.FTime, A7);
end;

constructor TMultiTargetCombatSpellCA.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FTargetIDs := TByteList.Create;
end;

destructor TMultiTargetCombatSpellCA.Destroy;
begin
  FTargetIDs.Free;
  inherited Destroy;
end;

procedure TMultiTargetCombatSpellCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(FSourceID, 20);
  Stream.rwStreamProc(21, FTargetIDs.LoadFromStream, FTargetIDs.SaveToStream);
  Stream.rwInteger(FManaCost, 22);
  Stream.rwBool(FSucceeded, 23);
  Stream.rwInteger(FSpellID, 24);
end;

procedure TMultiTargetCombatSpellCA.Execute(A1: TCombat);
var
  Source: TCombatObject;
begin
  with A1 do
  if (FManaCost <> 0) and (cExecuting in FStatus) then
  begin
    Source := FCombatData.FindID(FSourceID);
    AoWHSSet.FSpellControl.GetSpell(FSpellID).CombatCastingDone(Source, FManaCost);
  end;
end;

function TMultiTargetCombatSpellCA.Play(A1: TCombatViewer): Boolean;
begin
  if A1.FTime = 0 then
    AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastSounds.Play(0);
  if A1.FDelay = A1.FTime then Execute(A1.FCombat);
  Result := A1.FDelay * 5 > A1.FTime;
end;

procedure TMultiTargetCombatSpellCA.ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc);
begin
  if A2.FID = FSourceID then
    A2.ShowAttackAnimation(A1.FTime, A4, A5, A6, A7)
  else inherited ShowObject(A1, A2, A3, A4, A5, A6, A7);
  if A2.FID = FSourceID then
    AoWEngine.FCombatFont.SetTextCentered(A5 + 32, A6 + 32 + 8,
      AoWHSSet.FSpellControl.GetSpell(FSpellID).FSpellName, A7)
  else if FTargetIDs.IndexOf(A2.FID) <> -1 then
    AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastImages.Show(11,
      A5 + 32, A6 + 32, A1.FTime, A7);
end;

procedure TMultiTargetCombatSpellCA.ShowFieldObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc);
begin
  { Original calls ShowObject here, bypassing inherited field markers. }
  inherited ShowObject(A1, A2, A3, A4, A5, A6, A7);
  if A2.FID = FSourceID then
    AoWEngine.FCombatFont.SetTextCentered(A5 + 32, A6 + 32 + 8,
      AoWHSSet.FSpellControl.GetSpell(FSpellID).FSpellName, A7)
  else if FTargetIDs.IndexOf(A2.FID) <> -1 then
    AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastImages.Show(11,
      A5 + 32, A6 + 32, A1.FTime, A7);
end;

procedure TMultiTargetCombatSpellCA.ShowFightingObjects(A1: TCombatViewer; A2: Integer; A3: Integer; A4: Integer; const A5: TSurfaceDesc);
var
  Source: TCombatObject;
begin
  Source := A1.FCombat.FCombatData.FindID(FSourceID);
  A1.DefaultShowFightingObjects(nil, Source, A2, A3, A4, A5);
end;

constructor TCombatSpell.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellType := stCombat;
  FSpellControlTypes := [sctCombat];
  FCombatInfo.Radius := 1;
  FCombatInfo.TargetTypes := [cttEnemy];
  FCastDuration := 5;
  FDamageMode := 0;
end;

procedure TCombatSpell.GetCombatInfo(Source: TAbstractUnit; var Info: TSpellCombatInfo);
begin
  Info := FCombatInfo;
end;

function TCombatSpell.GetCombatDamageValue(A1, A2: TCombatObject): Integer;
begin
  Result := StatisticsToLimitedDV(FCombatInfo.Attack, FCombatInfo.Damage,
    FCombatInfo.DamageTypes, A2.GetHitPoints, A2.GetDefense, A2.GetResistance,
    A2.GetImmunityTypes, A2.GetProtectionTypes) * FCombatInfo.RepeatCount;
end;

function TCombatSpell.CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction;
var
  Action: TCombatSpellCA;
begin
  Action := TCombatSpellCA.Create(nil);
  Action.FSpellID := FSpellID;
  Action.GenerateEx(A1, A2, FCombatInfo.Attack, FCombatInfo.Damage,
    FCombatInfo.DamageTypes, FDamageMode);
  if A3 then
    Action.FManaCost := THero(TCombatUnit(A1).FUnit).CastingMana(Self);
  Result := Action;
end;

procedure TCombatSpell.GetCombatDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues);
var
  Protection, Immunity: TDamageTypes;
begin
  Protection := A2.GetProtectionTypes;
  Immunity := A2.GetImmunityTypes;
  A3.DamageTypes := FCombatInfo.DamageTypes;
  A3.SourceDamage := StatisticsToLimitedDV(FCombatInfo.Attack, FCombatInfo.Damage,
    FCombatInfo.DamageTypes, A2.GetHitPoints, A2.GetDefense, A2.GetResistance,
    Immunity, Protection) * FCombatInfo.RepeatCount;
  { Original recomputes the value, using resistance in place of defense for mode 1. }
  if FDamageMode = 1 then
    A3.SourceDamage := StatisticsToLimitedDV(FCombatInfo.Attack, FCombatInfo.Damage,
      FCombatInfo.DamageTypes, A2.GetHitPoints, A2.GetResistance, A2.GetResistance,
      Immunity, Protection) * FCombatInfo.RepeatCount
  else
    A3.SourceDamage := StatisticsToLimitedDV(FCombatInfo.Attack, FCombatInfo.Damage,
      FCombatInfo.DamageTypes, A2.GetHitPoints, A2.GetDefense, A2.GetResistance,
      Immunity, Protection) * FCombatInfo.RepeatCount;
  A3.SourceCost := StatisticsToMaxDamage(FCombatInfo.Damage, FCombatInfo.DamageTypes,
    Protection, Immunity) * FCombatInfo.RepeatCount;
  A3.TargetDamage := 0;
  A3.TargetCost := 0;
end;

procedure TCombatSpell.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
var
  DamageTypes, Protection, Immunity: TDamageTypes;
  Count, I, Distance: Integer;
  Other: TCombatObject;
  Combat: TFastCombat;
  Damage, Defense: Integer;
begin
  with A2 do
  begin
    if (A3 = wsNone) or (FCombatInfo.Range = -1) or (FCombatInfo.Range >= 8) then
    begin
      Protection := GetProtectionTypes;
      Immunity := GetImmunityTypes;
      DamageTypes := FCombatInfo.DamageTypes;
      Damage := FCombatInfo.Damage;
      Defense := GetDefense;
      if (A3 = wsTarget) and ([dtMagic, dtDeath, dtHoly] * FCombatInfo.DamageTypes = []) then
        Inc(Defense, 2);
      A4.DamageTypes := DamageTypes;
      A4.SourceDamage := StatisticsToLimitedDV(FCombatInfo.Attack, Damage, DamageTypes,
        GetHitPoints, Defense, GetResistance, Immunity, Protection) * FCombatInfo.RepeatCount;
      if FCombatInfo.Radius > 1 then
        A4.SourceDamage := (A4.SourceDamage * FCombatInfo.Radius) shr 1;
      A4.SourceCost := StatisticsToMaxDamage(Damage, DamageTypes, Protection, Immunity) * FCombatInfo.RepeatCount;
      A4.TargetDamage := 0;
      A4.TargetCost := 0;
      if (A4.SourceDamage <> 0) and (FCombatInfo.Radius > 1) then
      begin
        Combat := TFastCombat(A1.FCombat);
        Count := 0;
        Distance := Combat.GetRoundDistance;
        if FCombatInfo.Range = -1 then Inc(Distance, 8)
        else if FCombatInfo.Range >= 12 then Inc(Distance, 4)
        else if FCombatInfo.Range >= 8 then Inc(Distance, 2);
        for I := Combat.FSides[GetSide].GetCount - 1 downto 0 do
        begin
          Other := Combat.FSides[GetSide].GetObjects(I);
          if (A2 <> Other) and Other.GetEnabled and
            (Other.FPosition shr 4 = FPosition shr 4) and
            (Other.fcRoundDistance <= Distance) and
            (DamageTypes - Other.GetImmunityTypes <> []) then Inc(Count);
        end;
        if Count <> 0 then
        begin
          if FCombatInfo.Radius < Count then Count := FCombatInfo.Radius;
          Inc(A4.SourceDamage, Round((A4.SourceDamage * Count) * 0.5));
        end;
      end;
    end
    else
    begin
      A4.SourceDamage := 0;
      A4.SourceCost := 0;
      A4.TargetDamage := 0;
      A4.TargetCost := 0;
      A4.DamageTypes := [];
    end;
  end;
end;

procedure TCombatSpell.fcPrefetchCombatCommands(A1: TFastCombatCommandList);
var
  Hero: TAbstractUnit;
  Distance, I: Integer;
  Reason: string;
  Target: TCombatObject;
  Command: TSpellCC;
  Values: TAbilityDamageValues;
begin
  Hero := TCombatUnit(A1.FSource).FUnit;
  if (Hero is THero) and THero(Hero).CanCastSpellInstantly(FSpellID, FBaseManaCost, Reason) then
  begin
    Distance := A1.FCombat.GetRoundDistance;
    if FCombatInfo.Range = -1 then Inc(Distance, 8)
    else if FCombatInfo.Range >= 12 then Inc(Distance, 4)
    else if FCombatInfo.Range >= 8 then Inc(Distance, 2);
    for I := 0 to A1.FTargetSide.GetCount - 1 do
    begin
      Target := A1.FTargetSide.GetObjects(I);
      if Target.GetEnabled and (Target.fcRoundDistance <= Distance) then
      begin
        fcGetDamageValueEx(A1.FSource, Target,
          TFastCombat(A1.FSource.FCombat).GetWallSituation(A1.FSource, Target), Values);
        if Values.SourceDamage <> 0 then
        begin
          Command := TSpellCC.Create(52);
          Command.FTarget := A1.FTargetSide.GetObjects(I);
          Command.FMoveCost := 1;
          Command.FSpellID := FSpellID;
          Command.FExpectedDV := DVtoDEV(Values.SourceDamage, Values.TargetDamage, A1.FSource, Target);
          A1.Add(Command);
        end;
      end;
    end;
  end;
end;

function TCombatSpell.fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean;
var
  I, J, Count: Integer;
  Action: TCombatAction;
  Other: TCombatObject;
  Distance: Integer;
  Target: TCombatObject;
  Targets: TList;
  Combat: TFastCombat;
begin
  Target := A2.FTarget;
  for I := 0 to FCombatInfo.RepeatCount - 1 do
    if not (csDestroyed in Target.FStatus) then
    begin
      Action := CreateCA(A1, Target, I = 0);
      A1.FCombat.ExecuteCombatAction(Action);
      Action.Release;
    end;
  if FCombatInfo.Radius > 1 then
  begin
    Combat := TFastCombat(A1.FCombat);
    Targets := TList.Create;
    Distance := Combat.GetRoundDistance;
    if FCombatInfo.Range = -1 then Inc(Distance, 8)
    else if FCombatInfo.Range >= 12 then Inc(Distance, 4)
    else if FCombatInfo.Range >= 8 then Inc(Distance, 2);
    for I := Combat.FSides[Target.GetSide].GetCount - 1 downto 0 do
    begin
      Other := Combat.FSides[Target.GetSide].GetObjects(I);
      if (Other <> Target) and Other.GetEnabled and
        (Other.FPosition shr 4 = Target.FPosition shr 4) and
        (Distance >= Other.fcRoundDistance) and
        (FCombatInfo.DamageTypes - Other.GetImmunityTypes <> []) then Targets.Add(Other);
    end;
    { Original shifts Random(4) by two, so this adds no random extra targets. }
    Count := (AoWHSMap.Random(4) shr 2) + FCombatInfo.Radius;
    while (Count <> 0) and (Targets.Count <> 0) do
    begin
      Other := Targets[AoWHSMap.Random(Targets.Count)];
      for J := 0 to FCombatInfo.RepeatCount - 1 do
        if not (csDestroyed in Other.FStatus) then
        begin
          Action := CreateCA(A1, Other, False);
          A1.FCombat.ExecuteCombatAction(Action);
          Action.Release;
        end;
      Targets.Remove(Other);
      Dec(Count);
    end;
    Targets.Free;
  end;
  Result := True;
end;

constructor TSolarFlare.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(SolarFlareRStr);
  FSpellID := 100;
  with FCombatInfo do
  begin
    Attack := 8;
    Damage := 4;
    DamageTypes := [dtHoly];
    RepeatCount := 1;
    Range := 12;
  end;
end;


class function TTurnUndeadSpellCA.ClassID: Integer;
begin
  Result := $202CC;
end;


procedure TTurnUndeadSpellCA.Execute(A1: TCombat);
var
  Source: TCombatObject;
  Target: TCombatUnit;
  Data: TUnitEnchantmentAbilityData;
begin
  inherited Execute(A1);
  if FDamage <> 0 then
  begin
    Source := A1.FCombatData.FindID(FSourceID);
    Target := TCombatUnit(A1.FCombatData.FindID(FTargetID));
    if not (csDestroyed in Target.FStatus) then
    begin
      AoWHSSet.FAbilityControl.GetAbility(34).Expand(Target.FUnit);
      Data := TUnitEnchantmentAbilityData(Target.FUnit.GetAbilityData(34));
      if Data <> nil then Data.FEnchantmentPlayerIndex := Source.FCombatPlayer;
    end;
  end;
end;


constructor TTurnUndead.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(TurnUndeadRStr);
  FSpellID := 101;
  FDamageMode := 1;
  with FCombatInfo do
  begin
    Attack := 6;
    Damage := 5;
    DamageTypes := [dtHoly];
    RepeatCount := 1;
    Range := 12;
  end;
end;


function TTurnUndead.CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction;
var
  Action: TTurnUndeadSpellCA;
begin
  Action := TTurnUndeadSpellCA.Create(nil);
  Action.FSpellID := FSpellID;
  Action.FSourceID := A1.FID;
  Action.FTargetID := A2.FID;
  if A3 then Action.FManaCost := FBaseManaCost;
  if (A2 is TCombatUnit) and (TCombatUnit(A2).FUnit.GetUnitType in [utHumanoid, utCreature]) and
    ((TCombatUnit(A2).FUnit.GetRace = 11) or TCombatUnit(A2).FUnit.GetAbilityEnabled(129)) then
    Action.GenerateEx(A1, A2, FCombatInfo.Attack, FCombatInfo.Damage,
      FCombatInfo.DamageTypes, FDamageMode);
  Result := Action;
end;


procedure TTurnUndead.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
begin
  if (A2 is TCombatUnit) and (TCombatUnit(A2).FUnit.GetUnitType in [utHumanoid, utCreature]) and
    ((TCombatUnit(A2).FUnit.GetRace = 11) or TCombatUnit(A2).FUnit.GetAbilityEnabled(129)) then
    inherited fcGetDamageValueEx(A1, A2, A3, A4)
  else
  begin
    A4.SourceDamage := 0;
    A4.SourceCost := 0;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [];
  end;
end;

class function TFastCombatHighPrayerCA.ClassID: Integer;
begin
  Result := $202C7;
end;


procedure TFastCombatHighPrayerCA.Execute(A1: TCombat);
var
  I: Integer;
  Target: TCombatObject;
begin
  inherited Execute(A1);
  for I := FTargetIDs.Count - 1 downto 0 do
  begin
    Target := A1.FCombatData.FindID(FTargetIDs[I]);
    Target.SetHitPoints(Target.GetHitPoints + 5);
    AoWHSSet.FAbilityControl.GetAbility(100).Expand(TCombatUnit(Target).FUnit);
  end;
end;


procedure TFastCombatHighPrayerCA.Generate(A1: TCombatObject);
var
  I: Integer;
  Side: TCombatSide;
  Target: TCombatObject;
begin
  FSpellID := 102;
  FSourceID := A1.FID;
  with A1.FCombat do Side := FSides[A1.GetSide];
  for I := Side.GetCount - 1 downto 0 do
  begin
    Target := Side.GetObjects(I);
    if (Target is TCombatUnit) and not (csDestroyed in Target.FStatus) then
      FTargetIDs.Add(Target.FID);
  end;
end;


class function TTacticalCombatHighPrayerCA.ClassID: Integer;
begin
  Result := $202CA;
end;


procedure TTacticalCombatHighPrayerCA.Execute(A1: TCombat);
var
  Target: TCombatObject;
begin
  inherited Execute(A1);
  if FSucceeded then
  begin
    Target := A1.FCombatData.FindID(FTargetID);
    Target.SetHitPoints(Target.GetHitPoints + 5);
    AoWHSSet.FAbilityControl.GetAbility(100).Expand(TCombatUnit(Target).FUnit);
  end;
end;


constructor THighPrayer.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(HighPrayerRStr);
  FSpellID := 102;
  with FCombatInfo do
  begin
    Attack := 6;
    Damage := 0;
    DamageTypes := [];
    RepeatCount := 1;
    Range := -1;
    TargetTypes := [cttFriend];
  end;
end;


function THighPrayer.CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction;
var
  Action: TTacticalCombatHighPrayerCA;
begin
  Action := TTacticalCombatHighPrayerCA.Create(nil);
  Action.FSucceeded := True;
  Action.FSourceID := A1.FID;
  Action.FTargetID := A2.FID;
  Action.FSpellID := FSpellID;
  if A3 then Action.FManaCost := FBaseManaCost;
  Result := Action;
end;

procedure THighPrayer.fcPrefetchCombatCommands(A1: TFastCombatCommandList);
var
  I: Integer;
  Side: TCombatSide;
  Target: TCombatObject;
  Value: Integer;
  Command: TSpellCC;
begin
  Value := 0;
  Side := A1.FCombat.FSides[A1.FSource.GetSide];
  for I := Side.GetCount - 1 downto 0 do
  begin
    Target := Side.GetObjects(I);
    if (Target.FCombatValue <> 0) and (Target is TCombatUnit) then
      Inc(Value, DVtoDEV((Target.GetHits - Target.GetHitPoints) * 100, 0, A1.FSource, Target));
  end;
  if Value <> 0 then
  begin
    Command := TSpellCC.Create(52);
    Command.FTarget := nil;
    Command.FMoveCost := 1;
    Command.FSpellID := FSpellID;
    Command.FExpectedDV := Value;
    A1.Add(Command);
  end;
end;


function THighPrayer.fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean;
var
  Action: TFastCombatHighPrayerCA;
begin
  Action := TFastCombatHighPrayerCA.Create(nil);
  Action.Generate(A1);
  Action.FManaCost := THero(TCombatUnit(A1).FUnit).CastingMana(Self);
  A1.FCombat.ExecuteCombatAction(Action);
  Action.Release;
  Result := True;
end;


procedure THighPrayer.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
var
  I, Value, Healing: Integer;
  Side: TCombatSide;
  Target: TCombatObject;
begin
  Value := 0;
  Side := A1.FCombat.FSides[A1.GetSide];
  for I := Side.GetCount - 1 downto 0 do
  begin
    Target := Side.GetObjects(I);
    if (Target.FCombatValue <> 0) and (Target is TCombatUnit) then
    begin
      Healing := Target.GetHits - Target.GetHitPoints;
      if Healing > 5 then Healing := 5;
      Inc(Value, Healing * 100);
    end;
  end;
  if Value <> 0 then
  begin
    A4.SourceDamage := Value;
    A4.SourceCost := Value div 100;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [dtDeath];
  end
  else
  begin
    A4.SourceDamage := 0;
    A4.SourceCost := 0;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [];
  end;
end;


procedure THighPrayer.tcGetDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues);
var
  Healing, Value: Integer;
begin
  Healing := A2.GetHits - A2.GetHitPoints;
  if Healing > 5 then Healing := 5;
  Value := Healing * 100;
  if Value <> 0 then
  begin
    A3.SourceDamage := Value;
    A3.SourceCost := Value div 100;
    A3.TargetDamage := 0;
    A3.TargetCost := 0;
    A3.DamageTypes := [dtDeath];
  end
  else
  begin
    A3.SourceDamage := 0;
    A3.SourceCost := 0;
    A3.TargetDamage := 0;
    A3.TargetCost := 0;
    A3.DamageTypes := [];
  end;
end;


constructor TDeathRay.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(DeathRayRStr);
  FSpellID := 103;
  with FCombatInfo do
  begin
    Attack := 8;
    Damage := 4;
    DamageTypes := [dtDeath];
    RepeatCount := 1;
    Range := 12;
  end;
end;


constructor TDiseaseCloud.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(DiseaseCloudRStr);
  FSpellID := 104;
  with FCombatInfo do
  begin
    Attack := 6;
    Damage := 3;
    DamageTypes := [dtDeath];
    RepeatCount := 1;
    Range := 12;
  end;
end;


class function TMindDecayCA.ClassID: Integer;
begin
  Result := $202CB;
end;


procedure TMindDecayCA.Execute(A1: TCombat);
var
  Source: TCombatObject;
  Target: TCombatUnit;
  I: Integer;
begin
  inherited Execute(A1);
  if FSucceeded then
  begin
    Source := A1.FCombatData.FindID(FSourceID);
    Target := TCombatUnit(A1.FCombatData.FindID(FTargetID));
    Source.SetExperience(Source.GetExperience + Target.GetLevel);
    for I := 0 to 2 do
      TCommandAbility(AoWHSSet.FAbilityControl.GetAbility(CommandAbilityIDs[I])).ResetCommandedUnits(Target);
    for I := 0 to 2 do
      TCommandAbility(AoWHSSet.FAbilityControl.GetAbility(CommandAbilityIDs[I])).Uncommand(Target);
    AoWHSSet.FAbilityControl.GetAbility(131).Expand(Target.FUnit);
    Target.SetCombatPlayer(Source.FCombatPlayer);
  end;
end;


constructor TMindDecay.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(MindDecayRStr);
  FSpellID := 106;
  with FCombatInfo do
  begin
    Attack := 5;
    Damage := 0;
    DamageTypes := [dtNone];
    RepeatCount := 1;
    Range := 12;
    Radius := 3;
  end;
end;


function TMindDecay.CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction;
var
  Action: TMindDecayCA;
begin
  Action := TMindDecayCA.Create(nil);
  Action.FSourceID := A1.FID;
  Action.FTargetID := A2.FID;
  Action.FSpellID := FSpellID;
  if A3 then Action.FManaCost := FBaseManaCost;
  if (A2 is TCombatUnit) and (TCombatUnit(A2).FUnit.GetUnitType <> utMachine) and
    (TCombatUnit(A2).FUnit.GetRace <> 11) and not TCombatUnit(A2).FUnit.GetAbilityEnabled(129) and
    not (TCombatUnit(A2).FUnit is TLeader) then
    Action.FSucceeded := HitRole(FCombatInfo.Attack - A2.GetResistance);
  Result := Action;
end;


constructor TChainLightning.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(ChainLightningRStr);
  FSpellID := 107;
  with FCombatInfo do
  begin
    Attack := 6;
    Damage := 4;
    DamageTypes := [dtLightning];
    RepeatCount := 1;
    Range := 12;
    Radius := 3;
  end;
end;


constructor TColdBreath.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(ColdBreathRStr);
  FSpellID := 108;
  with FCombatInfo do
  begin
    Attack := 6;
    Damage := 5;
    DamageTypes := [dtCold];
    RepeatCount := 1;
    Range := 4;
  end;
end;


class function TSlowCA.ClassID: Integer;
begin
  Result := $202D0;
end;


procedure TSlowCA.Execute(A1: TCombat);
var
  Target: TCombatUnit;
  Source: TCombatObject;
  Enchantment: TUnitEnchantment;
begin
  inherited Execute(A1);
  if FSucceeded then
  begin
    Target := TCombatUnit(A1.FCombatData.FindID(FTargetID));
    Source := A1.FCombatData.FindID(FSourceID);
    if Target.FUnit.ExpandAbility(132) then
    begin
      Enchantment := TUnitEnchantmentAbilityData(Target.FUnit.GetAbilityData(132)).FEnchantment;
      Enchantment.SetUpkeep(0);
      Enchantment.SetSource(Source.GetPlayer);
    end;
  end;
end;


constructor TSlow.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(SlowRStr);
  FSpellID := 110;
  with FCombatInfo do
  begin
    Attack := 9;
    Damage := 0;
    DamageTypes := [dtNone];
    RepeatCount := 1;
    Range := 12;
  end;
end;


procedure TSlow.GetCombatDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues);
begin
  with A3 do
  begin
    SourceDamage := 0;
    SourceCost := 0;
    TargetDamage := 0;
    TargetCost := 0;
    DamageTypes := [];
  end;
end;


function TSlow.CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction;
var
  Action: TSlowCA;
begin
  Action := TSlowCA.Create(nil);
  Action.FSourceID := A1.FID;
  Action.FTargetID := A2.FID;
  Action.FSpellID := FSpellID;
  if A3 then Action.FManaCost := FBaseManaCost;
  if not A2.GetAbilityEnabled(132) then
    Action.FSucceeded := HitRole(FCombatInfo.Attack - A2.GetResistance);
  Result := Action;
end;


class function TEntangleSpellCA.ClassID: Integer;
begin
  Result := $202C8;
end;


procedure TEntangleSpellCA.Execute(A1: TCombat);
var
  Source: TCombatObject;
  Target: TCombatUnit;
  Data: TUnitEnchantmentAbilityData;
begin
  inherited Execute(A1);
  if FSucceeded then
  begin
    Source := A1.FCombatData.FindID(FSourceID);
    Target := TCombatUnit(A1.FCombatData.FindID(FTargetID));
    AoWHSSet.FAbilityControl.GetAbility(94).Expand(Target.FUnit);
    Data := TUnitEnchantmentAbilityData(Target.FUnit.GetAbilityData(94));
    if Data <> nil then Data.FEnchantmentPlayerIndex := Source.FCombatPlayer;
  end;
end;


constructor TEntangle.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(EntangleRStr);
  FSpellID := 111;
  with FCombatInfo do
  begin
    Attack := 7;
    Damage := 0;
    DamageTypes := [dtNone];
    RepeatCount := 1;
    Range := 12;
  end;
end;


function TEntangle.CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction;
var
  Action: TEntangleSpellCA;
begin
  Action := TEntangleSpellCA.Create(nil);
  Action.FSourceID := A1.FID;
  Action.FTargetID := A2.FID;
  Action.FSpellID := FSpellID;
  if A3 then Action.FManaCost := FBaseManaCost;
  if not A2.GetAbilityEnabled(1) and not A2.GetAbilityEnabled(94) then
    Action.FSucceeded := HitRole(FCombatInfo.Attack - A2.GetResistance);
  Result := Action;
end;


procedure TEntangle.GetCombatDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues);
begin
  if not A2.GetAbilityEnabled(1) and not A2.GetAbilityEnabled(94) then
  begin
    A3.SourceDamage := Round((A2.GetHitPoints * 100) * HitRoleProbability(FCombatInfo.Attack - A2.GetResistance));
    A3.SourceCost := A2.GetHitPoints;
    A3.TargetDamage := 0;
    A3.TargetCost := 0;
    A3.DamageTypes := [dtNone];
  end
  else
  begin
    A3.SourceDamage := 0;
    A3.SourceCost := 0;
    A3.TargetDamage := 0;
    A3.TargetCost := 0;
    A3.DamageTypes := [];
  end;
end;


constructor TTremors.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TremorsRStr; { Original leaves this spell name untranslated. }
  FSpellID := 112;
  with FCombatInfo do
  begin
    Attack := 6;
    Damage := 5;
    DamageTypes := [dtPhysical, dtWall];
    RepeatCount := 1;
    Range := -1;
    Radius := 5;
  end;
end;


constructor TCallFlames.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(CallFlamesRStr);
  FSpellID := 113;
  with FCombatInfo do
  begin
    Attack := 9;
    Damage := 3;
    DamageTypes := [dtFire];
    RepeatCount := 1;
    Range := 8;
    Radius := 1;
  end;
end;


constructor TFireBreath.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(FireBreathRStr);
  FSpellID := 114;
  with FCombatInfo do
  begin
    Attack := 6;
    Damage := 5;
    DamageTypes := [dtFire];
    RepeatCount := 1;
    Range := 4;
    Radius := 3;
  end;
end;


constructor TSwarm.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(SwarmRStr);
  FSpellID := 115;
  with FCombatInfo do
  begin
    Attack := 6;
    Damage := 2;
    DamageTypes := [dtFire];
    RepeatCount := 1;
    Range := 12;
    Radius := 5;
  end;
end;


constructor TGreatHail.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(GreatHailRStr);
  FSpellID := 116;
  with FCombatInfo do
  begin
    Attack := 5;
    Damage := 5;
    DamageTypes := [dtPhysical, dtWall];
    RepeatCount := 3;
    Range := 12;
    Radius := 2;
  end;
end;


constructor TFireBall.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(FireBallRStr);
  FSpellID := 117;
  with FCombatInfo do
  begin
    Attack := 8;
    Damage := 6;
    DamageTypes := [dtFire, dtWall];
    RepeatCount := 1;
    Range := 12;
  end;
end;


constructor TGeyser.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(GeyserRStr);
  FSpellID := 118;
  with FCombatInfo do
  begin
    Attack := 9;
    Damage := 5;
    DamageTypes := [dtPhysical];
    RepeatCount := 1;
    Range := 12;
    Radius := 1;
  end;
end;


function TGeyser.CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction;
var
  Action: TCombatSpellCA;
begin
  Action := TCombatSpellCA.Create(nil);
  Action.FSpellID := FSpellID;
  if A2.GetAbilityEnabled(1) or A2.GetAbilityEnabled(59) then
    Action.Generate(A1, A2, FCombatInfo.Attack, FCombatInfo.Damage div 2, FCombatInfo.DamageTypes)
  else
    Action.Generate(A1, A2, FCombatInfo.Attack, FCombatInfo.Damage, FCombatInfo.DamageTypes);
  if A3 then Action.FManaCost := THero(TCombatUnit(A1).FUnit).CastingMana(Self);
  Result := Action;
end;


constructor TIceShards.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(IceShardsRStr);
  FSpellID := 119;
  with FCombatInfo do
  begin
    Attack := 6;
    Damage := 4;
    DamageTypes := [dtPhysical];
    RepeatCount := 3;
    Range := 12;
  end;
end;


constructor TFrostBeams.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(FrostBeamsRStr);
  FSpellID := 120;
  with FCombatInfo do
  begin
    Attack := 9;
    Damage := 3;
    DamageTypes := [dtCold];
    RepeatCount := 1;
    Range := 12;
    Radius := 3;
  end;
end;


constructor TVaporize.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(VaporizeRStr);
  FSpellID := 121;
  FDamageMode := 1;
  with FCombatInfo do
  begin
    Attack := 7;
    Damage := 5;
    DamageTypes := [dtPhysical];
    RepeatCount := 1;
    Range := 12;
  end;
end;


constructor TStoning.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(StoningRStr);
  FSpellID := 122;
  with FCombatInfo do
  begin
    Attack := 5;
    Damage := 2;
    DamageTypes := [dtPhysical];
    RepeatCount := 6;
    Range := 12;
  end;
end;


constructor TFlamingArrow.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(FlamingArrowRStr);
  FSpellID := 123;
  with FCombatInfo do
  begin
    Attack := 8;
    Damage := 4;
    DamageTypes := [dtFire, dtPhysical];
    RepeatCount := 1;
    Range := 12;
  end;
end;


constructor TOoze.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(OozeRStr);
  FSpellID := 124;
  with FCombatInfo do
  begin
    Attack := 0;
    Damage := 0;
    DamageTypes := [];
    RepeatCount := 0;
    Range := 8;
  end;
end;


procedure TOoze.GetCombatDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues);
var
  Protection, Immunity: TDamageTypes;
begin
  Protection := A2.GetProtectionTypes;
  Immunity := A2.GetImmunityTypes;
  A3.DamageTypes := FCombatInfo.DamageTypes;
  A3.SourceDamage := Round(HitRoleProbability(FCombatInfo.Attack - A2.GetResistance) * 200);
  A3.SourceCost := 200;
  A3.TargetDamage := 0;
  A3.TargetCost := 0;
end;


constructor TSacredWrath.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(SacredWrathRStr);
  FSpellID := 125;
  with FCombatInfo do
  begin
    Attack := 6;
    Damage := 5;
    DamageTypes := [dtHoly];
    RepeatCount := 1;
    Range := 8;
    Radius := 3;
  end;
end;


class function TFastCombatTerrorCA.ClassID: Integer;
begin
  Result := $202C1;
end;


procedure TFastCombatTerrorCA.Execute(A1: TCombat);
var
  I: Integer;
  Target: TCombatUnit;
begin
  inherited Execute(A1);
  for I := FTargetIDs.Count - 1 downto 0 do
  begin
    Target := TCombatUnit(A1.FCombatData.FindID(FTargetIDs[I]));
    AoWHSSet.FAbilityControl.GetAbility(108).Expand(Target.FUnit);
  end;
end;


procedure TFastCombatTerrorCA.Generate(A1: TCombatObject);
var
  I: Integer;
  Side: TCombatSide;
  Target: TCombatObject;
begin
  FSpellID := 105;
  FSourceID := A1.FID;
  with A1.FCombat do Side := FSides[A1.GetOpponentSide];
  for I := Side.GetCount - 1 downto 0 do
  begin
    Target := Side.GetObjects(I);
    if not (csDestroyed in Target.FStatus) and not Target.GetAbilityEnabled(108) and
      not Target.GetAbilityEnabled(67) and (Target is TCombatUnit) and
      not (dtDeath in Target.GetImmunityTypes) and
      (TCombatUnit(Target).FUnit.GetUnitType <> utMachine) and
      HitRole(6 - Target.GetResistance) then FTargetIDs.Add(Target.FID);
  end;
end;


class function TTacticalCombatTerrorCA.ClassID: Integer;
begin
  Result := $202C9;
end;


procedure TTacticalCombatTerrorCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(FSourceID, 20);
  Stream.rwByte(FTargetID, 21);
  Stream.rwInteger(FManaCost, 22);
  Stream.rwBool(FSucceeded, 23);
end;


procedure TTacticalCombatTerrorCA.Execute(A1: TCombat);
var
  Target, Source: TCombatUnit;
begin
  if FSucceeded then
  begin
    Target := TCombatUnit(A1.FCombatData.FindID(FTargetID));
    AoWHSSet.FAbilityControl.GetAbility(108).Expand(Target.FUnit);
  end;
  if (FManaCost <> 0) and (cExecuting in A1.FStatus) then
  begin
    Source := TCombatUnit(A1.FCombatData.FindID(FSourceID));
    AoWHSSet.FSpellControl.GetSpell(105).CastingDone(Source.FUnit, FManaCost);
  end;
end;


function TTacticalCombatTerrorCA.Play(A1: TCombatViewer): Boolean;
begin
  Execute(A1.FCombat);
  Result := False;
end;


procedure TTacticalCombatTerrorCA.Generate(A1, A2: TCombatObject);
begin
  FSucceeded := False;
  FSourceID := A1.FID;
  FTargetID := A2.FID;
  if not A2.GetAbilityEnabled(108) and not A2.GetAbilityEnabled(67) and
    (A2 is TCombatUnit) and not (dtDeath in A2.GetImmunityTypes) and
    (TCombatUnit(A2).FUnit.GetUnitType <> utMachine) then
    FSucceeded := HitRole(6 - A2.GetResistance);
end;


constructor TTerror.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(TerrorRStr);
  FSpellID := 105;
  with FCombatInfo do
  begin
    Attack := 6;
    Damage := 0;
    DamageTypes := [dtDeath];
    RepeatCount := 1;
    Range := -1;
  end;
end;


function TTerror.CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction;
var
  Action: TTacticalCombatTerrorCA;
begin
  Action := TTacticalCombatTerrorCA.Create(nil);
  Action.Generate(A1, A2);
  if A3 then Action.FManaCost := THero(TCombatUnit(A1).FUnit).CastingMana(Self);
  Result := Action;
end;


procedure TTerror.fcPrefetchCombatCommands(A1: TFastCombatCommandList);
var
  I: Integer;
  Side: TCombatSide;
  Target: TCombatObject;
  Value: Integer;
  Command: TSpellCC;
begin
  Value := 0;
  Side := A1.FCombat.FSides[A1.FSource.GetOpponentSide];
  for I := Side.GetCount - 1 downto 0 do
  begin
    Target := Side.GetObjects(I);
    if not Target.GetAbilityEnabled(108) and (Target.FCombatValue <> 0) and
      (Target is TCombatUnit) and not (dtDeath in Target.GetImmunityTypes) then
      Inc(Value, Target.GetTargetPriority);
  end;
  if Value <> 0 then
  begin
    Command := TSpellCC.Create(52);
    Command.FTarget := nil;
    Command.FMoveCost := 1;
    Command.FSpellID := FSpellID;
    Command.FExpectedDV := Value;
    A1.Add(Command);
  end;
end;


function TTerror.fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean;
var
  Action: TFastCombatTerrorCA;
begin
  Action := TFastCombatTerrorCA.Create(nil);
  Action.Generate(A1);
  Action.FManaCost := THero(TCombatUnit(A1).FUnit).CastingMana(Self);
  A1.FCombat.ExecuteCombatAction(Action);
  Action.Release;
  Result := True;
end;


procedure TTerror.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
var
  I, Value: Integer;
  Side: TCombatSide;
  Target: TCombatObject;
begin
  Value := 0;
  Side := A1.FCombat.FSides[A1.GetOpponentSide];
  for I := Side.GetCount - 1 downto 0 do
  begin
    Target := Side.GetObjects(I);
    if not Target.GetAbilityEnabled(108) and (Target.FCombatValue <> 0) and
      (Target is TCombatUnit) and not (dtDeath in Target.GetImmunityTypes) then
      Inc(Value, Round(HitRoleProbability(6 - Target.GetResistance) * 100));
  end;
  if Value <> 0 then
  begin
    A4.SourceDamage := Value;
    A4.SourceCost := Value div 100;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [dtDeath];
  end
  else
  begin
    A4.SourceDamage := 0;
    A4.SourceCost := 0;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [];
  end;
end;


procedure TTerror.tcGetDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues);
var
  Value: Integer;
begin
  if not A2.GetAbilityEnabled(108) and (A2.FCombatValue <> 0) and
    (A2 is TCombatUnit) and not (dtDeath in A2.GetImmunityTypes) then
    Value := Round(HitRoleProbability(6 - A2.GetResistance) * 100)
  else Value := 0;
  if Value <> 0 then
  begin
    A3.SourceDamage := Value;
    A3.SourceCost := Value div 100;
    A3.TargetDamage := 0;
    A3.TargetCost := 0;
    A3.DamageTypes := [dtDeath];
  end
  else
  begin
    A3.SourceDamage := 0;
    A3.SourceCost := 0;
    A3.TargetDamage := 0;
    A3.TargetCost := 0;
    A3.DamageTypes := [];
  end;
end;


constructor TWindsOfFury.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(WindsOfFuryRStr);
  FSpellID := 126;
  with FCombatInfo do
  begin
    Attack := 8;
    Damage := 5;
    DamageTypes := [dtPhysical];
    RepeatCount := 1;
    Range := 12;
  end;
end;

function TWindsOfFury.CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction;
var
  Action: TCombatSpellCA;
begin
  Action := TCombatSpellCA.Create(nil);
  Action.FSpellID := FSpellID;
  if A2.GetAbilityEnabled(1) or A2.GetAbilityEnabled(59) then
    Action.Generate(A1, A2, FCombatInfo.Attack + 2, FCombatInfo.Damage, FCombatInfo.DamageTypes)
  else
    Action.Generate(A1, A2, FCombatInfo.Attack, FCombatInfo.Damage, FCombatInfo.DamageTypes);
  if A3 then
    Action.FManaCost := THero(TCombatUnit(A1).FUnit).CastingMana(Self);
  Result := Action;
end;

constructor TShockwave.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(ShockwaveRStr);
  FSpellID := 127;
  with FCombatInfo do
  begin
    Attack := 8;
    Damage := 5;
    DamageTypes := [dtPhysical, dtWall];
    RepeatCount := 1;
    Range := 12;
  end;
end;

constructor TSacrificialFlame.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(SacrificialFlameRStr);
  FSpellID := 128;
  with FCombatInfo do
  begin
    Attack := 8;
    Damage := 5;
    DamageTypes := [dtFire];
    RepeatCount := 1;
    Range := 12;
    Radius := 3;
  end;
end;

class function TRecallSpiritCA.ClassID: Integer;
begin Result := 131781; end;

procedure TRecallSpiritCA.Execute(A1: TCombat);
var
  Source, Target: TCombatUnit;
  NewUnit: TUnit;
begin
  inherited Execute(A1);
  if FSucceeded then
  begin
    Source := TCombatUnit(A1.FCombatData.FindID(FSourceID));
    Target := TCombatUnit(A1.FCombatData.FindID(FTargetID));
    NewUnit := TUnit.Create(nil);
    NewUnit.SetUnitResource(AoWHSSet.FUnitResources.GetUnitResource(130));
    NewUnit.SetPlayer(Source.FUnit.FPlayer);
    NewUnit.ExpandAbility(130);
    NewUnit.Activate;
    Target.SetUnit(NewUnit);
    NewUnit.Release;
    Target.SetStatus(Target.FStatus - [csDestroyed]);
    Target.SetCombatPlayer(Source.FCombatPlayer);
  end;
end;

constructor TRecallSpirit.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(RecallSpiritRStr);
  FSpellID := 129;
  with FCombatInfo do
  begin
    Attack := 0;
    Damage := 0;
    DamageTypes := [];
    RepeatCount := 1;
    Range := -1;
  end;
end;

procedure TRecallSpirit.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
begin
  if csDestroyed in A2.FStatus then
  begin
    { Original leaves the other damage-value fields unchanged on success. }
    A4.SourceDamage := 200;
    A4.DamageTypes := [];
  end
  else
  begin
    A4.SourceDamage := 0;
    A4.SourceCost := 0;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [];
  end;
end;

function TRecallSpirit.CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction;
var
  Action: TRecallSpiritCA;
begin
  Action := TRecallSpiritCA.Create(nil);
  Action.FSourceID := A1.FID;
  Action.FTargetID := A2.FID;
  Action.FSucceeded := csDestroyed in A2.FStatus;
  Action.FSpellID := FSpellID;
  if A3 then Action.FManaCost := FBaseManaCost;
  Result := Action;
end;

class function TAnimateDeadCA.ClassID: Integer;
begin Result := 131782; end;

procedure TAnimateDeadCA.Execute(A1: TCombat);
var
  Source, Target: TCombatUnit;
  NewUnit: TUnit;
begin
  inherited Execute(A1);
  if FSucceeded then
  begin
    Source := TCombatUnit(A1.FCombatData.FindID(FSourceID));
    Target := TCombatUnit(A1.FCombatData.FindID(FTargetID));
    NewUnit := TUnit.Create(nil);
    NewUnit.SetUnitResource(AoWHSSet.FUnitResources.GetUnitResource(201));
    NewUnit.SetPlayer(Source.FUnit.FPlayer);
    NewUnit.ExpandAbility(130);
    NewUnit.Activate;
    Target.SetUnit(NewUnit);
    NewUnit.Release;
    Target.SetStatus(Target.FStatus - [csDestroyed]);
    Target.SetCombatPlayer(Source.FCombatPlayer);
  end;
end;

constructor TAnimateDead.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(AnimateDeadRStr);
  FSpellID := 130;
  with FCombatInfo do
  begin
    Attack := 0;
    Damage := 0;
    DamageTypes := [];
    RepeatCount := 1;
    Range := -1;
  end;
end;

procedure TAnimateDead.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
begin
  if csDestroyed in A2.FStatus then
  begin
    { Original leaves the other damage-value fields unchanged on success. }
    A4.SourceDamage := 200;
    A4.DamageTypes := [];
  end
  else
  begin
    A4.SourceDamage := 0;
    A4.SourceCost := 0;
    A4.TargetDamage := 0;
    A4.TargetCost := 0;
    A4.DamageTypes := [];
  end;
end;

function TAnimateDead.CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction;
var
  Action: TAnimateDeadCA;
begin
  Action := TAnimateDeadCA.Create(nil);
  Action.FSourceID := A1.FID;
  Action.FTargetID := A2.FID;
  Action.FSucceeded := csDestroyed in A2.FStatus;
  Action.FSpellID := FSpellID;
  if A3 then Action.FManaCost := FBaseManaCost;
  Result := Action;
end;

procedure RegisterCombatSpells(Engine: TAoWEngine);
var
  Control: TSpellControl;
begin
  Control := Engine.FGameSet.FSpellControl;
  Engine.RegisterEClasses([TCombatSpellCA, TFastCombatTerrorCA, TTacticalCombatTerrorCA, TRecallSpiritCA, TAnimateDeadCA, TFastCombatHighPrayerCA, TTacticalCombatHighPrayerCA, TEntangleSpellCA, TMindDecayCA, TTurnUndeadSpellCA, TSlowCA]);
  Control.RegisterSpell(TSolarFlare.Create(nil));
  Control.RegisterSpell(TTurnUndead.Create(nil));
  Control.RegisterSpell(THighPrayer.Create(nil));
  Control.RegisterSpell(TDeathRay.Create(nil));
  Control.RegisterSpell(TDiseaseCloud.Create(nil));
  Control.RegisterSpell(TTerror.Create(nil));
  Control.RegisterSpell(TMindDecay.Create(nil));
  Control.RegisterSpell(TChainLightning.Create(nil));
  Control.RegisterSpell(TColdBreath.Create(nil));
  Control.RegisterSpell(TSlow.Create(nil));
  Control.RegisterSpell(TEntangle.Create(nil));
  Control.RegisterSpell(TTremors.Create(nil));
  Control.RegisterSpell(TCallFlames.Create(nil));
  Control.RegisterSpell(TFireBreath.Create(nil));
  Control.RegisterSpell(TSwarm.Create(nil));
  Control.RegisterSpell(TGreatHail.Create(nil));
  Control.RegisterSpell(TFireBall.Create(nil));
  Control.RegisterSpell(TGeyser.Create(nil));
  Control.RegisterSpell(TIceShards.Create(nil));
  Control.RegisterSpell(TFrostBeams.Create(nil));
  Control.RegisterSpell(TVaporize.Create(nil));
  Control.RegisterSpell(TStoning.Create(nil));
  Control.RegisterSpell(TFlamingArrow.Create(nil));
  Control.RegisterSpell(TOoze.Create(nil));
  Control.RegisterSpell(TSacredWrath.Create(nil));
  Control.RegisterSpell(TAnimateDead.Create(nil));
  Control.RegisterSpell(TRecallSpirit.Create(nil));
  Control.RegisterSpell(TWindsOfFury.Create(nil));
  Control.RegisterSpell(TShockwave.Create(nil));
  Control.RegisterSpell(TSacrificialFlame.Create(nil));
end;

procedure UnregisterCombatSpells(Engine: TAoWEngine);
var
  Control: TSpellControl;
begin
  Control := Engine.FGameSet.FSpellControl;
  Engine.UnregisterEClasses([TCombatSpellCA, TFastCombatTerrorCA, TTacticalCombatTerrorCA, TRecallSpiritCA, TAnimateDeadCA, TFastCombatHighPrayerCA, TTacticalCombatHighPrayerCA, TEntangleSpellCA, TMindDecayCA, TTurnUndeadSpellCA, TSlowCA]);
  Control.UnregisterSpellID(100);
  Control.UnregisterSpellID(101);
  Control.UnregisterSpellID(102);
  Control.UnregisterSpellID(103);
  Control.UnregisterSpellID(104);
  Control.UnregisterSpellID(105);
  Control.UnregisterSpellID(106);
  Control.UnregisterSpellID(107);
  Control.UnregisterSpellID(108);
  Control.UnregisterSpellID(110);
  Control.UnregisterSpellID(111);
  Control.UnregisterSpellID(112);
  Control.UnregisterSpellID(113);
  Control.UnregisterSpellID(114);
  Control.UnregisterSpellID(115);
  Control.UnregisterSpellID(116);
  Control.UnregisterSpellID(117);
  Control.UnregisterSpellID(118);
  Control.UnregisterSpellID(119);
  Control.UnregisterSpellID(120);
  Control.UnregisterSpellID(121);
  Control.UnregisterSpellID(122);
  Control.UnregisterSpellID(123);
  Control.UnregisterSpellID(124);
  Control.UnregisterSpellID(125);
  Control.UnregisterSpellID(130);
  Control.UnregisterSpellID(129);
  Control.UnregisterSpellID(126);
  Control.UnregisterSpellID(127);
  Control.UnregisterSpellID(128);
end;


initialization
finalization

end.
