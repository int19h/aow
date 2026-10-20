unit Storms;

{ Draft declarations of Storms, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, Animation, AoWE;

type
  TStorm = class;
  TStormDamageInfo = record
    Reserved00: array[0..11] of Byte;
    FriendlyDamage: Integer; { $0C }
    EnemyDamage: Integer; { $10 }
  end;
  TBlastStorm = class;
  TIceStorm = class;
  TDeathStorm = class;
  TDivineStorm = class;
  TLightningStorm = class;
  TFireStorm = class;
  TPestilenceStorm = class;
  TStormSpellTE = class;
  TStormSpell = class;
  TFireStormSpell = class;
  TDivineStormSpell = class;
  TDeathStormSpell = class;
  TIceStormSpell = class;
  TLightningStormSpell = class;
  TPestilenceStormSpell = class;


  { TStorm (instance size 64, VMT 557CB0BC) }
  TStorm = class(TAnimation)
  public
    F_Storm_3C: array[0..3] of Byte;
    procedure GetTargetDamageInfo(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); virtual; abstract;  { +124 draft }
    procedure UpdateTargetSelection(Selection: TTargetSelectionControl); virtual;
    procedure InitializeStorm(Player, X, Y, L: Shortint); virtual;
    function UpdateStorm: Boolean; virtual;
    procedure FinalizeStorm; virtual;  { +134 draft }
    class function Name: string; virtual; abstract;
    procedure ShowTargetSelection(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    function GetBestTarget(Player: Shortint; X, Y, L, Range: Integer; var Target: TXYL; var Info: TStormDamageInfo): Boolean;
  end;

  { TBlastStorm (instance size 68, VMT 557CB260) }
  TBlastStorm = class(TStorm)
  public
    F_BlastStorm_40: array[0..3] of Byte;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure GetTargetDamageInfo(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
    procedure UpdateTargetSelection(Selection: TTargetSelectionControl); override;
    procedure InitializeStorm(Player, X, Y, L: Shortint); override;
    function UpdateStorm: Boolean; override;
    procedure FinalizeStorm; override;
    procedure ChangeStormTerrain(A1: Integer; A2: Integer; A3: Integer); virtual;  { +13C draft }
    procedure StormTerrainChanged(A1: Integer; A2: Integer; A3: Integer); virtual;  { +140 draft }
    procedure StormFileName(A1: Integer); virtual;  { +144 draft }
    procedure StormType; virtual;  { +148 draft }
  end;

  { TIceStorm (instance size 68, VMT 557CB41C) }
  TIceStorm = class(TBlastStorm)
  public
    class function ClassID: Integer; override;
    class function Name: string; override;
    procedure ChangeStormTerrain(A1: Integer; A2: Integer; A3: Integer); override;
    procedure StormTerrainChanged(A1: Integer; A2: Integer; A3: Integer); override;
    procedure StormFileName(A1: Integer); override;
    procedure StormType; override;
  end;

  { TDeathStorm (instance size 68, VMT 557CB5D8) }
  TDeathStorm = class(TBlastStorm)
  public
    class function ClassID: Integer; override;
    class function Name: string; override;
    procedure ChangeStormTerrain(A1: Integer; A2: Integer; A3: Integer); override;
    procedure StormFileName(A1: Integer); override;
    procedure StormType; override;
  end;

  { TDivineStorm (instance size 68, VMT 557CB794) }
  TDivineStorm = class(TBlastStorm)
  public
    class function ClassID: Integer; override;
    class function Name: string; override;
    procedure ChangeStormTerrain(A1: Integer; A2: Integer; A3: Integer); override;
    procedure StormFileName(A1: Integer); override;
    procedure StormType; override;
  end;

  { TLightningStorm (instance size 68, VMT 557CB958) }
  TLightningStorm = class(TStorm)
  public
    F_LightningStorm_40: array[0..3] of Byte;
    class function ClassID: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure GetTargetDamageInfo(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
    procedure UpdateTargetSelection(Selection: TTargetSelectionControl); override;
    procedure InitializeStorm(Player, X, Y, L: Shortint); override;
    function UpdateStorm: Boolean; override;
    procedure FinalizeStorm; override;
    class function Name: string; override;
  end;

  { TFireStorm (instance size 64, VMT 557CBB0C) }
  TFireStorm = class(TStorm)
  public
    class function ClassID: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure GetTargetDamageInfo(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
    procedure UpdateTargetSelection(Selection: TTargetSelectionControl); override;
    procedure InitializeStorm(Player, X, Y, L: Shortint); override;
    function UpdateStorm: Boolean; override;
    procedure FinalizeStorm; override;
    class function Name: string; override;
    procedure ChangeStormTerrain(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;

  { TPestilenceStorm (instance size 68, VMT 557CBCB8) }
  TPestilenceStorm = class(TStorm)
  public
    F_PestilenceStorm_40: array[0..3] of Byte;
    class function ClassID: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure GetTargetDamageInfo(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
    procedure UpdateTargetSelection(Selection: TTargetSelectionControl); override;
    procedure InitializeStorm(Player, X, Y, L: Shortint); override;
    function UpdateStorm: Boolean; override;
    procedure FinalizeStorm; override;
    class function Name: string; override;
  end;

  { TStormSpellTE (instance size 40, VMT 557CBE74) }
  TStormSpellTE = class(TSpellTE)
  public
    F_StormSpellTE_20: array[0..3] of Byte;
    F_StormSpellTE_24: Byte;
    F_StormSpellTE_25: Byte;
    F_StormSpellTE_26: Byte;
    F_StormSpellTE_27: array[0..0] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Process(A1: TAbstractUnit; A2: Integer): Boolean; override;
  end;

  { TStormSpell (instance size 60, VMT 557CBF48) }
  TStormSpell = class(TSpell)
  public
    F_StormSpell_34: array[0..7] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure AIPrefetchCastSpellActions(A1: TAbstractUnit; A2: TAICastSpellActionList); override;
    function AIExecuteCastSpellAction(A1: TAbstractUnit): Boolean; override;
    function CanActivate(A1: TAbstractUnit; var A2: string): Boolean; override;
    function Activate(A1: TAbstractUnit): Boolean; override;
    procedure CreateStorm; virtual; abstract;  { +09C draft }
    procedure ExecuteStormSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +0A0 draft }
    procedure AICastSpellPriority(A1: Integer); virtual;  { +0A4 draft }
    procedure OnTargetSelectionChange(A1: Integer);  { draft }
  end;

  { TFireStormSpell (instance size 60, VMT 557CC060) }
  TFireStormSpell = class(TStormSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateStorm; override;
  end;

  { TDivineStormSpell (instance size 60, VMT 557CC180) }
  TDivineStormSpell = class(TStormSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateStorm; override;
  end;

  { TDeathStormSpell (instance size 60, VMT 557CC2A8) }
  TDeathStormSpell = class(TStormSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateStorm; override;
  end;

  { TIceStormSpell (instance size 60, VMT 557CC3D0) }
  TIceStormSpell = class(TStormSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateStorm; override;
  end;

  { TLightningStormSpell (instance size 60, VMT 557CC4F0) }
  TLightningStormSpell = class(TStormSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateStorm; override;
  end;

  { TPestilenceStormSpell (instance size 60, VMT 557CC620) }
  TPestilenceStormSpell = class(TStormSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateStorm; override;
  end;

procedure RegisterStorms(A1: Integer);  { draft }
procedure UnRegisterStorms(A1: Integer);  { draft }

implementation

procedure TStorm.InitializeStorm(Player, X, Y, L: Shortint);
begin end;

function TStorm.UpdateStorm: Boolean;
begin Result := False; end;

procedure TStorm.FinalizeStorm;
begin end;

procedure TStorm.ShowTargetSelection(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TStorm.UpdateTargetSelection(Selection: TTargetSelectionControl);
begin end;

function TStorm.GetBestTarget(Player: Shortint; X, Y, L, Range: Integer; var Target: TXYL; var Info: TStormDamageInfo): Boolean;
begin Result := False; end;

procedure TBlastStorm.InitializeStorm(Player, X, Y, L: Shortint);
begin end;

procedure TBlastStorm.StormFileName(A1: Integer);
begin end;

procedure TBlastStorm.StormType;
begin end;

procedure TBlastStorm.ChangeStormTerrain(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TBlastStorm.StormTerrainChanged(A1: Integer; A2: Integer; A3: Integer);
begin end;

function TBlastStorm.UpdateStorm: Boolean;
begin Result := False; end;

procedure TBlastStorm.FinalizeStorm;
begin end;

procedure TBlastStorm.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TBlastStorm.UpdateTargetSelection(Selection: TTargetSelectionControl);
begin end;

procedure TBlastStorm.GetTargetDamageInfo(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

class function TIceStorm.ClassID: Integer;
begin Result := 0; end;

class function TIceStorm.Name: string;
begin Result := ''; end;

procedure TIceStorm.StormTerrainChanged(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TIceStorm.ChangeStormTerrain(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TIceStorm.StormFileName(A1: Integer);
begin end;

procedure TIceStorm.StormType;
begin end;

class function TLightningStorm.ClassID: Integer;
begin Result := 0; end;

class function TLightningStorm.Name: string;
begin Result := ''; end;

procedure TLightningStorm.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TLightningStorm.InitializeStorm(Player, X, Y, L: Shortint);
begin end;

procedure TLightningStorm.FinalizeStorm;
begin end;

function TLightningStorm.UpdateStorm: Boolean;
begin Result := False; end;

procedure TLightningStorm.UpdateTargetSelection(Selection: TTargetSelectionControl);
begin end;

procedure TLightningStorm.GetTargetDamageInfo(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

class function TDeathStorm.ClassID: Integer;
begin Result := 0; end;

class function TDeathStorm.Name: string;
begin Result := ''; end;

procedure TDeathStorm.ChangeStormTerrain(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TDeathStorm.StormFileName(A1: Integer);
begin end;

procedure TDeathStorm.StormType;
begin end;

class function TFireStorm.ClassID: Integer;
begin Result := 0; end;

class function TFireStorm.Name: string;
begin Result := ''; end;

procedure TFireStorm.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TFireStorm.InitializeStorm(Player, X, Y, L: Shortint);
begin end;

procedure TFireStorm.FinalizeStorm;
begin end;

procedure TFireStorm.ChangeStormTerrain(A1: Integer; A2: Integer; A3: Integer);
begin end;

function TFireStorm.UpdateStorm: Boolean;
begin Result := False; end;

procedure TFireStorm.UpdateTargetSelection(Selection: TTargetSelectionControl);
begin end;

procedure TFireStorm.GetTargetDamageInfo(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

class function TDivineStorm.ClassID: Integer;
begin Result := 0; end;

class function TDivineStorm.Name: string;
begin Result := ''; end;

procedure TDivineStorm.ChangeStormTerrain(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TDivineStorm.StormFileName(A1: Integer);
begin end;

procedure TDivineStorm.StormType;
begin end;

class function TPestilenceStorm.ClassID: Integer;
begin Result := 0; end;

class function TPestilenceStorm.Name: string;
begin Result := ''; end;

procedure TPestilenceStorm.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TPestilenceStorm.InitializeStorm(Player, X, Y, L: Shortint);
begin end;

procedure TPestilenceStorm.FinalizeStorm;
begin end;

function TPestilenceStorm.UpdateStorm: Boolean;
begin Result := False; end;

procedure TPestilenceStorm.UpdateTargetSelection(Selection: TTargetSelectionControl);
begin end;

procedure TPestilenceStorm.GetTargetDamageInfo(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

class function TStormSpellTE.ClassID: Integer;
begin Result := 0; end;

procedure TStormSpellTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TStormSpellTE.Process(A1: TAbstractUnit; A2: Integer): Boolean;
begin Result := False; end;

constructor TStormSpell.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TStormSpell.ExecuteStormSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TStormSpell.OnTargetSelectionChange(A1: Integer);
begin end;

function TStormSpell.CanActivate(A1: TAbstractUnit; var A2: string): Boolean;
begin Result := False; end;

function TStormSpell.Activate(A1: TAbstractUnit): Boolean;
begin Result := False; end;

procedure TStormSpell.AICastSpellPriority(A1: Integer);
begin end;

procedure TStormSpell.AIPrefetchCastSpellActions(A1: TAbstractUnit; A2: TAICastSpellActionList);
begin end;

function TStormSpell.AIExecuteCastSpellAction(A1: TAbstractUnit): Boolean;
begin Result := False; end;

constructor TFireStormSpell.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TFireStormSpell.CreateStorm;
begin end;

constructor TDivineStormSpell.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TDivineStormSpell.CreateStorm;
begin end;

constructor TDeathStormSpell.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TDeathStormSpell.CreateStorm;
begin end;

constructor TIceStormSpell.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TIceStormSpell.CreateStorm;
begin end;

constructor TPestilenceStormSpell.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TPestilenceStormSpell.CreateStorm;
begin end;

constructor TLightningStormSpell.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TLightningStormSpell.CreateStorm;
begin end;

procedure RegisterStorms(A1: Integer);
begin end;

procedure UnRegisterStorms(A1: Integer);
begin end;


initialization
finalization

end.
