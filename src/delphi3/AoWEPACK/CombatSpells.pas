unit CombatSpells;

{ Draft declarations of CombatSpells, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  The combat action bases and TCombatSpell are recovered; later classes remain drafts. }

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

  { TSolarFlare (instance size 64, VMT 557F40BC) }
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

  { TTurnUndead (instance size 64, VMT 557F42C8) }
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
    procedure Generate(A1: Integer);  { draft }
  end;

  { TTacticalCombatHighPrayerCA (instance size 28, VMT 557F44D0) }
  TTacticalCombatHighPrayerCA = class(TExclusiveCombatSpellCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
  end;

  { THighPrayer (instance size 64, VMT 557F45CC) }
  THighPrayer = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction; override;
    procedure tcGetDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues); override;
    procedure fcPrefetchCombatCommands(A1: TFastCombatCommandList); override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues); override;
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
    procedure Execute(A1: TCombat); override;
  end;

  { TMindDecay (instance size 64, VMT 557F49E8) }
  TMindDecay = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction; override;
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
    procedure Execute(A1: TCombat); override;
  end;

  { TSlow (instance size 64, VMT 557F4E00) }
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

  { TEntangle (instance size 64, VMT 557F4FF0) }
  TEntangle = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction; override;
    procedure GetCombatDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues); override;
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
    function CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction; override;
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
    procedure GetCombatDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues); override;
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
    procedure Execute(A1: TCombat); override;
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
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
    procedure Generate(A1: Integer; A2: Integer);  { draft }
  end;

  { TTerror (instance size 64, VMT 557F61D4) }
  TTerror = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction; override;
    procedure tcGetDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues); override;
    procedure fcPrefetchCombatCommands(A1: TFastCombatCommandList); override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues); override;
  end;

  { TWindsOfFury (instance size 64, VMT 557F62E0) }
  TWindsOfFury = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction; override;
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
    procedure Execute(A1: TCombat); override;
  end;

  { TRecallSpirit (instance size 64, VMT 557F6710) }
  TRecallSpirit = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction; override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues); override;
  end;

  { TAnimateDeadCA (instance size 28, VMT 557F6828) }
  TAnimateDeadCA = class(TExclusiveCombatSpellCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
  end;

  { TAnimateDead (instance size 64, VMT 557F690C) }
  TAnimateDead = class(TCombatSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction; override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues); override;
  end;

procedure RegisterCombatSpells(A1: Integer);  { draft }
procedure UnregisterCombatSpells(A1: Integer);  { draft }

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
begin end;

class function TTurnUndeadSpellCA.ClassID: Integer;
begin Result := 0; end;

procedure TTurnUndeadSpellCA.Execute(A1: TCombat);
begin end;

constructor TTurnUndead.Create(AOwner: Engine.TECustomNode);
begin end;

function TTurnUndead.CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction;
begin Result := nil; end;

procedure TTurnUndead.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
begin end;

class function TFastCombatHighPrayerCA.ClassID: Integer;
begin Result := 0; end;

procedure TFastCombatHighPrayerCA.Execute(A1: TCombat);
begin end;

procedure TFastCombatHighPrayerCA.Generate(A1: Integer);
begin end;

class function TTacticalCombatHighPrayerCA.ClassID: Integer;
begin Result := 0; end;

procedure TTacticalCombatHighPrayerCA.Execute(A1: TCombat);
begin end;

constructor THighPrayer.Create(AOwner: Engine.TECustomNode);
begin end;

function THighPrayer.CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction;
begin Result := nil; end;

procedure THighPrayer.fcPrefetchCombatCommands(A1: TFastCombatCommandList);
begin end;

function THighPrayer.fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean;
begin Result := False; end;

procedure THighPrayer.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
begin end;

procedure THighPrayer.tcGetDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues);
begin end;

constructor TDeathRay.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TDiseaseCloud.Create(AOwner: Engine.TECustomNode);
begin end;

class function TMindDecayCA.ClassID: Integer;
begin Result := 0; end;

procedure TMindDecayCA.Execute(A1: TCombat);
begin end;

constructor TMindDecay.Create(AOwner: Engine.TECustomNode);
begin end;

function TMindDecay.CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction;
begin Result := nil; end;

constructor TChainLightning.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TColdBreath.Create(AOwner: Engine.TECustomNode);
begin end;

class function TSlowCA.ClassID: Integer;
begin Result := 0; end;

procedure TSlowCA.Execute(A1: TCombat);
begin end;

constructor TSlow.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TSlow.GetCombatDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues);
begin end;

function TSlow.CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction;
begin Result := nil; end;

class function TEntangleSpellCA.ClassID: Integer;
begin Result := 0; end;

procedure TEntangleSpellCA.Execute(A1: TCombat);
begin end;

constructor TEntangle.Create(AOwner: Engine.TECustomNode);
begin end;

function TEntangle.CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction;
begin Result := nil; end;

procedure TEntangle.GetCombatDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues);
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

function TGeyser.CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction;
begin Result := nil; end;

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

procedure TOoze.GetCombatDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues);
begin end;

constructor TSacredWrath.Create(AOwner: Engine.TECustomNode);
begin end;

class function TFastCombatTerrorCA.ClassID: Integer;
begin Result := 0; end;

procedure TFastCombatTerrorCA.Execute(A1: TCombat);
begin end;

procedure TFastCombatTerrorCA.Generate(A1: Integer);
begin end;

class function TTacticalCombatTerrorCA.ClassID: Integer;
begin Result := 0; end;

procedure TTacticalCombatTerrorCA.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TTacticalCombatTerrorCA.Execute(A1: TCombat);
begin end;

function TTacticalCombatTerrorCA.Play(A1: TCombatViewer): Boolean;
begin Result := False; end;

procedure TTacticalCombatTerrorCA.Generate(A1: Integer; A2: Integer);
begin end;

constructor TTerror.Create(AOwner: Engine.TECustomNode);
begin end;

function TTerror.CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction;
begin Result := nil; end;

procedure TTerror.fcPrefetchCombatCommands(A1: TFastCombatCommandList);
begin end;

function TTerror.fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean;
begin Result := False; end;

procedure TTerror.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
begin end;

procedure TTerror.tcGetDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues);
begin end;

constructor TWindsOfFury.Create(AOwner: Engine.TECustomNode);
begin end;

function TWindsOfFury.CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction;
begin Result := nil; end;

constructor TShockwave.Create(AOwner: Engine.TECustomNode);
begin end;

constructor TSacrificialFlame.Create(AOwner: Engine.TECustomNode);
begin end;

class function TRecallSpiritCA.ClassID: Integer;
begin Result := 0; end;

procedure TRecallSpiritCA.Execute(A1: TCombat);
begin end;

constructor TRecallSpirit.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TRecallSpirit.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
begin end;

function TRecallSpirit.CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction;
begin Result := nil; end;

class function TAnimateDeadCA.ClassID: Integer;
begin Result := 0; end;

procedure TAnimateDeadCA.Execute(A1: TCombat);
begin end;

constructor TAnimateDead.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TAnimateDead.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
begin end;

function TAnimateDead.CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction;
begin Result := nil; end;

procedure RegisterCombatSpells(A1: Integer);
begin end;

procedure UnregisterCombatSpells(A1: Integer);
begin end;


initialization
finalization

end.
