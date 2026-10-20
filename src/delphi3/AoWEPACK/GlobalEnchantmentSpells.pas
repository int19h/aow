unit GlobalEnchantmentSpells;

{ Draft declarations of GlobalEnchantmentSpells, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TGlobalEnchantmentSpellTE = class;
  TGlobalEnchantmentSpell = class;
  TEnchantedRoadsEnchantment = class;
  TEnchantedRoads = class;
  TAirMasteryEnchantment = class;
  TAirMastery = class;
  TWaterMasteryEnchantment = class;
  TWaterMastery = class;
  THatredEnchantment = class;
  THatred = class;
  THarmonyEnchantment = class;
  THarmony = class;
  TPowerLeakEnchantment = class;
  TPowerLeak = class;
  TFloodControl = class;
  TFloodEnchantment = class;
  TFlood = class;
  TLifeMasteryEnchantment = class;
  TLifeMastery = class;
  TDeathMasteryEnchantment = class;
  TDeathMastery = class;
  TFireMasteryEnchantment = class;
  TFireMastery = class;
  TEarthMasteryEnchantment = class;
  TEarthMastery = class;
  TSpellWardEnchantment = class;
  TSpellWard = class;


  { TGlobalEnchantmentSpellTE (instance size 36, VMT 557ED91C) }
  TGlobalEnchantmentSpellTE = class(TSpellTE)
  public
    F_GlobalEnchantmentSpellTE_20: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Validate(A1: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
  end;

  { TGlobalEnchantmentSpell (instance size 56, VMT 557EDA18) }
  TGlobalEnchantmentSpell = class(TSpell)
  public
    F_GlobalEnchantmentSpell_34: Integer;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ExecuteTE(A1: Integer; A2: Integer; A3: Integer); override;
    procedure AIPrefetchCastSpellActions(A1: Integer; A2: Integer); override;
    procedure AIExecuteCastSpellAction(A1: Integer); override;
    procedure CanActivate(A1: Integer; A2: Integer); override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure AICanCastSpell(A1: Integer); virtual;  { +09C draft }
    procedure CreateEnchantment; virtual;  { +0A0 draft }
    procedure SetupEnchantment(A1: Integer; A2: Integer); virtual;  { +0A4 draft }
    procedure AIUpkeepPriority;  { draft }
  end;

  { TEnchantedRoadsEnchantment (instance size 36, VMT 557EDB5C) }
  TEnchantedRoadsEnchantment = class(TGlobalEnchantment)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GetAIUpkeepPriority; override;
    procedure Deactivate(A1: Byte); override;
    procedure CanActivate(A1: Integer; A2: Integer); override;
    procedure Activate(A1: Byte; A2: Integer); override;
  end;

  { TEnchantedRoads (instance size 56, VMT 557EDC88) }
  TEnchantedRoads = class(TGlobalEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ExecuteTE(A1: Integer; A2: Integer; A3: Integer); override;
    procedure CreateEnchantment; override;
    procedure ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
  end;

  { TAirMasteryEnchantment (instance size 36, VMT 557EDDBC) }
  TAirMasteryEnchantment = class(TGlobalEnchantment)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GetAIUpkeepPriority; override;
    procedure Deactivate(A1: Byte); override;
    procedure CanActivate(A1: Integer; A2: Integer); override;
    procedure Activate(A1: Byte; A2: Integer); override;
  end;

  { TAirMastery (instance size 56, VMT 557EDEE0) }
  TAirMastery = class(TGlobalEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ExecuteTE(A1: Integer; A2: Integer; A3: Integer); override;
    procedure CreateEnchantment; override;
    procedure ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
  end;

  { TWaterMasteryEnchantment (instance size 36, VMT 557EE00C) }
  TWaterMasteryEnchantment = class(TGlobalEnchantment)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GetAIUpkeepPriority; override;
    procedure Deactivate(A1: Byte); override;
    procedure CanActivate(A1: Integer; A2: Integer); override;
    procedure Activate(A1: Byte; A2: Integer); override;
  end;

  { TWaterMastery (instance size 56, VMT 557EE138) }
  TWaterMastery = class(TGlobalEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ExecuteTE(A1: Integer; A2: Integer; A3: Integer); override;
    procedure CreateEnchantment; override;
  end;

  { THatredEnchantment (instance size 40, VMT 557EE268) }
  THatredEnchantment = class(TGlobalEnchantment)
  public
    F_HatredEnchantment_24: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure GetAIUpkeepPriority; override;
    procedure Deactivate(A1: Byte); override;
    procedure Activate(A1: Byte; A2: Integer); override;
    procedure NewDay;  { draft }
  end;

  { THatred (instance size 56, VMT 557EE384) }
  THatred = class(TGlobalEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ExecuteTE(A1: Integer; A2: Integer; A3: Integer); override;
    procedure CreateEnchantment; override;
  end;

  { THarmonyEnchantment (instance size 40, VMT 557EE4A8) }
  THarmonyEnchantment = class(TGlobalEnchantment)
  public
    F_HarmonyEnchantment_24: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure GetAIUpkeepPriority; override;
    procedure Deactivate(A1: Byte); override;
    procedure Activate(A1: Byte; A2: Integer); override;
    procedure NewDay;  { draft }
  end;

  { THarmony (instance size 56, VMT 557EE5C8) }
  THarmony = class(TGlobalEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ExecuteTE(A1: Integer; A2: Integer; A3: Integer); override;
    procedure CreateEnchantment; override;
  end;

  { TPowerLeakEnchantment (instance size 36, VMT 557EE6F0) }
  TPowerLeakEnchantment = class(TGlobalEnchantment)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GetAIUpkeepPriority; override;
    procedure Deactivate(A1: Byte); override;
    procedure Activate(A1: Byte; A2: Integer); override;
  end;

  { TPowerLeak (instance size 56, VMT 557EE814) }
  TPowerLeak = class(TGlobalEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ExecuteTE(A1: Integer; A2: Integer; A3: Integer); override;
    procedure CreateEnchantment; override;
  end;

  { TFloodControl (instance size 20, VMT 557EE93C) }
  TFloodControl = class(TEObject)
  public
    F_FloodControl_08: Integer;
    F_FloodControl_0C: Integer;
    F_FloodControl_10: Byte;
    F_FloodControl_11: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Setup;  { draft }
    procedure Flood;  { draft }
    procedure Restore;  { draft }
  end;

  { TFloodEnchantment (instance size 48, VMT 557EEA10) }
  TFloodEnchantment = class(TGlobalEnchantment)
  public
    F_FloodEnchantment_24: Byte;
    F_FloodEnchantment_25: Byte;
    F_FloodEnchantment_26: Byte;
    F_FloodEnchantment_27: array[0..0] of Byte;
    F_FloodEnchantment_28: Integer;
    F_FloodEnchantment_2C: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure GetName(A1: Integer); override;
    procedure GetUpkeep; override;
    procedure GetAIUpkeepPriority; override;
    procedure CanDeactivate(A1: Integer; A2: Integer); override;
    procedure Deactivate(A1: Byte); override;
    procedure Activate(A1: Byte; A2: Integer); override;
    procedure DaysBeforeActive;  { draft }
    procedure NewTurn;  { draft }
  end;

  { TFlood (instance size 56, VMT 557EEB2C) }
  TFlood = class(TGlobalEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ExecuteTE(A1: Integer; A2: Integer; A3: Integer); override;
    procedure CreateEnchantment; override;
    procedure ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
  end;

  { TLifeMasteryEnchantment (instance size 36, VMT 557EEC4C) }
  TLifeMasteryEnchantment = class(TGlobalEnchantment)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GetAIUpkeepPriority; override;
    procedure Deactivate(A1: Byte); override;
    procedure CanActivate(A1: Integer; A2: Integer); override;
    procedure Activate(A1: Byte; A2: Integer); override;
  end;

  { TLifeMastery (instance size 56, VMT 557EED74) }
  TLifeMastery = class(TGlobalEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ExecuteTE(A1: Integer; A2: Integer; A3: Integer); override;
    procedure CreateEnchantment; override;
  end;

  { TDeathMasteryEnchantment (instance size 36, VMT 557EEEA4) }
  TDeathMasteryEnchantment = class(TGlobalEnchantment)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure GetAIUpkeepPriority; override;
    procedure Deactivate(A1: Byte); override;
    procedure CanActivate(A1: Integer; A2: Integer); override;
    procedure Activate(A1: Byte; A2: Integer); override;
    procedure NewTurn(A1: Byte);  { draft }
  end;

  { TDeathMastery (instance size 56, VMT 557EEFD0) }
  TDeathMastery = class(TGlobalEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ExecuteTE(A1: Integer; A2: Integer; A3: Integer); override;
    procedure CreateEnchantment; override;
    procedure ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
  end;

  { TFireMasteryEnchantment (instance size 36, VMT 557EF100) }
  TFireMasteryEnchantment = class(TGlobalEnchantment)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure GetAIUpkeepPriority; override;
    procedure Deactivate(A1: Byte); override;
    procedure CanActivate(A1: Integer; A2: Integer); override;
    procedure Activate(A1: Byte; A2: Integer); override;
    procedure UpdateFire(A1: Integer; A2: Byte);  { draft }
  end;

  { TFireMastery (instance size 56, VMT 557EF228) }
  TFireMastery = class(TGlobalEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ExecuteTE(A1: Integer; A2: Integer; A3: Integer); override;
    procedure CreateEnchantment; override;
    procedure ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
  end;

  { TEarthMasteryEnchantment (instance size 36, VMT 557EF358) }
  TEarthMasteryEnchantment = class(TGlobalEnchantment)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GetAIUpkeepPriority; override;
    procedure Deactivate(A1: Byte); override;
    procedure CanActivate(A1: Integer; A2: Integer); override;
    procedure Activate(A1: Byte; A2: Integer); override;
  end;

  { TEarthMastery (instance size 56, VMT 557EF484) }
  TEarthMastery = class(TGlobalEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ExecuteTE(A1: Integer; A2: Integer; A3: Integer); override;
    procedure CreateEnchantment; override;
    procedure ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
  end;

  { TSpellWardEnchantment (instance size 36, VMT 557EF5B4) }
  TSpellWardEnchantment = class(TGlobalEnchantment)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GetAIUpkeepPriority; override;
  end;

  { TSpellWard (instance size 56, VMT 557EF6D8) }
  TSpellWard = class(TGlobalEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ExecuteTE(A1: Integer; A2: Integer; A3: Integer); override;
    procedure CreateEnchantment; override;
  end;

procedure RegisterGlobalEnchantmentSpells(A1: Integer);  { draft }
procedure UnregisterGlobalEnchantmentSpells(A1: Integer);  { draft }

implementation

destructor TGlobalEnchantmentSpellTE.Destroy;
begin end;

class function TGlobalEnchantmentSpellTE.ClassID: Integer;
begin Result := 0; end;

procedure TGlobalEnchantmentSpellTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TGlobalEnchantmentSpellTE.Validate(A1: Integer);
begin end;

procedure TGlobalEnchantmentSpellTE.Process(A1: Integer; A2: Integer);
begin end;

constructor TGlobalEnchantmentSpell.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TGlobalEnchantmentSpell.CreateEnchantment;
begin end;

procedure TGlobalEnchantmentSpell.SetupEnchantment(A1: Integer; A2: Integer);
begin end;

procedure TGlobalEnchantmentSpell.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TGlobalEnchantmentSpell.CanActivate(A1: Integer; A2: Integer);
begin end;

procedure TGlobalEnchantmentSpell.Activate(A1: Integer; A2: Integer);
begin end;

procedure TGlobalEnchantmentSpell.AICanCastSpell(A1: Integer);
begin end;

procedure TGlobalEnchantmentSpell.AIUpkeepPriority;
begin end;

procedure TGlobalEnchantmentSpell.AIPrefetchCastSpellActions(A1: Integer; A2: Integer);
begin end;

procedure TGlobalEnchantmentSpell.AIExecuteCastSpellAction(A1: Integer);
begin end;

constructor TEnchantedRoadsEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

class function TEnchantedRoadsEnchantment.ClassID: Integer;
begin Result := 0; end;

procedure TEnchantedRoadsEnchantment.GetAIUpkeepPriority;
begin end;

procedure TEnchantedRoadsEnchantment.CanActivate(A1: Integer; A2: Integer);
begin end;

procedure TEnchantedRoadsEnchantment.Activate(A1: Byte; A2: Integer);
begin end;

procedure TEnchantedRoadsEnchantment.Deactivate(A1: Byte);
begin end;

constructor TEnchantedRoads.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TEnchantedRoads.ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TEnchantedRoads.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TEnchantedRoads.CreateEnchantment;
begin end;

constructor TAirMasteryEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

class function TAirMasteryEnchantment.ClassID: Integer;
begin Result := 0; end;

procedure TAirMasteryEnchantment.GetAIUpkeepPriority;
begin end;

procedure TAirMasteryEnchantment.CanActivate(A1: Integer; A2: Integer);
begin end;

procedure TAirMasteryEnchantment.Activate(A1: Byte; A2: Integer);
begin end;

procedure TAirMasteryEnchantment.Deactivate(A1: Byte);
begin end;

constructor TAirMastery.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TAirMastery.ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAirMastery.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAirMastery.CreateEnchantment;
begin end;

constructor TWaterMasteryEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

class function TWaterMasteryEnchantment.ClassID: Integer;
begin Result := 0; end;

procedure TWaterMasteryEnchantment.GetAIUpkeepPriority;
begin end;

procedure TWaterMasteryEnchantment.CanActivate(A1: Integer; A2: Integer);
begin end;

procedure TWaterMasteryEnchantment.Activate(A1: Byte; A2: Integer);
begin end;

procedure TWaterMasteryEnchantment.Deactivate(A1: Byte);
begin end;

procedure TWaterMastery.CreateEnchantment;
begin end;

constructor TWaterMastery.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TWaterMastery.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
begin end;

constructor THatredEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

class function THatredEnchantment.ClassID: Integer;
begin Result := 0; end;

procedure THatredEnchantment.GetAIUpkeepPriority;
begin end;

procedure THatredEnchantment.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure THatredEnchantment.NewDay;
begin end;

procedure THatredEnchantment.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure THatredEnchantment.Activate(A1: Byte; A2: Integer);
begin end;

procedure THatredEnchantment.Deactivate(A1: Byte);
begin end;

procedure THatred.CreateEnchantment;
begin end;

constructor THatred.Create(AOwner: Engine.TECustomNode);
begin end;

procedure THatred.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
begin end;

constructor THarmonyEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

class function THarmonyEnchantment.ClassID: Integer;
begin Result := 0; end;

procedure THarmonyEnchantment.GetAIUpkeepPriority;
begin end;

procedure THarmonyEnchantment.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure THarmonyEnchantment.NewDay;
begin end;

procedure THarmonyEnchantment.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure THarmonyEnchantment.Activate(A1: Byte; A2: Integer);
begin end;

procedure THarmonyEnchantment.Deactivate(A1: Byte);
begin end;

procedure THarmony.CreateEnchantment;
begin end;

constructor THarmony.Create(AOwner: Engine.TECustomNode);
begin end;

procedure THarmony.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
begin end;

constructor TPowerLeakEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

class function TPowerLeakEnchantment.ClassID: Integer;
begin Result := 0; end;

procedure TPowerLeakEnchantment.GetAIUpkeepPriority;
begin end;

procedure TPowerLeakEnchantment.Activate(A1: Byte; A2: Integer);
begin end;

procedure TPowerLeakEnchantment.Deactivate(A1: Byte);
begin end;

procedure TPowerLeak.CreateEnchantment;
begin end;

constructor TPowerLeak.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TPowerLeak.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
begin end;

constructor TFloodControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TFloodControl.Destroy;
begin end;

procedure TFloodControl.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TFloodControl.Setup;
begin end;

procedure TFloodControl.Flood;
begin end;

procedure TFloodControl.Restore;
begin end;

constructor TFloodEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TFloodEnchantment.Destroy;
begin end;

class function TFloodEnchantment.ClassID: Integer;
begin Result := 0; end;

procedure TFloodEnchantment.GetAIUpkeepPriority;
begin end;

procedure TFloodEnchantment.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TFloodEnchantment.DaysBeforeActive;
begin end;

procedure TFloodEnchantment.GetName(A1: Integer);
begin end;

procedure TFloodEnchantment.GetUpkeep;
begin end;

procedure TFloodEnchantment.NewTurn;
begin end;

procedure TFloodEnchantment.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TFloodEnchantment.Activate(A1: Byte; A2: Integer);
begin end;

procedure TFloodEnchantment.CanDeactivate(A1: Integer; A2: Integer);
begin end;

procedure TFloodEnchantment.Deactivate(A1: Byte);
begin end;

procedure TFlood.CreateEnchantment;
begin end;

constructor TFlood.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TFlood.ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TFlood.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
begin end;

constructor TLifeMasteryEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

class function TLifeMasteryEnchantment.ClassID: Integer;
begin Result := 0; end;

procedure TLifeMasteryEnchantment.GetAIUpkeepPriority;
begin end;

procedure TLifeMasteryEnchantment.CanActivate(A1: Integer; A2: Integer);
begin end;

procedure TLifeMasteryEnchantment.Activate(A1: Byte; A2: Integer);
begin end;

procedure TLifeMasteryEnchantment.Deactivate(A1: Byte);
begin end;

constructor TLifeMastery.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TLifeMastery.CreateEnchantment;
begin end;

procedure TLifeMastery.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
begin end;

constructor TDeathMasteryEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

class function TDeathMasteryEnchantment.ClassID: Integer;
begin Result := 0; end;

procedure TDeathMasteryEnchantment.GetAIUpkeepPriority;
begin end;

procedure TDeathMasteryEnchantment.CanActivate(A1: Integer; A2: Integer);
begin end;

procedure TDeathMasteryEnchantment.Activate(A1: Byte; A2: Integer);
begin end;

procedure TDeathMasteryEnchantment.Deactivate(A1: Byte);
begin end;

procedure TDeathMasteryEnchantment.NewTurn(A1: Byte);
begin end;

procedure TDeathMasteryEnchantment.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

constructor TDeathMastery.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TDeathMastery.CreateEnchantment;
begin end;

procedure TDeathMastery.ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TDeathMastery.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
begin end;

constructor TFireMasteryEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

class function TFireMasteryEnchantment.ClassID: Integer;
begin Result := 0; end;

procedure TFireMasteryEnchantment.GetAIUpkeepPriority;
begin end;

procedure TFireMasteryEnchantment.CanActivate(A1: Integer; A2: Integer);
begin end;

procedure TFireMasteryEnchantment.Activate(A1: Byte; A2: Integer);
begin end;

procedure TFireMasteryEnchantment.Deactivate(A1: Byte);
begin end;

procedure TFireMasteryEnchantment.UpdateFire(A1: Integer; A2: Byte);
begin end;

procedure TFireMasteryEnchantment.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

constructor TFireMastery.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TFireMastery.CreateEnchantment;
begin end;

procedure TFireMastery.ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TFireMastery.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
begin end;

constructor TEarthMasteryEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

class function TEarthMasteryEnchantment.ClassID: Integer;
begin Result := 0; end;

procedure TEarthMasteryEnchantment.GetAIUpkeepPriority;
begin end;

procedure TEarthMasteryEnchantment.CanActivate(A1: Integer; A2: Integer);
begin end;

procedure TEarthMasteryEnchantment.Activate(A1: Byte; A2: Integer);
begin end;

procedure TEarthMasteryEnchantment.Deactivate(A1: Byte);
begin end;

constructor TEarthMastery.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TEarthMastery.ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TEarthMastery.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TEarthMastery.CreateEnchantment;
begin end;

constructor TSpellWardEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

class function TSpellWardEnchantment.ClassID: Integer;
begin Result := 0; end;

procedure TSpellWardEnchantment.GetAIUpkeepPriority;
begin end;

constructor TSpellWard.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TSpellWard.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TSpellWard.CreateEnchantment;
begin end;

procedure RegisterGlobalEnchantmentSpells(A1: Integer);
begin end;

procedure UnregisterGlobalEnchantmentSpells(A1: Integer);
begin end;


initialization
finalization

end.
