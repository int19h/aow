unit GlobalTargetSpells;

{ Draft declarations of GlobalTargetSpells, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TGlobalTargetSpellTE = class;
  TGlobalTargetSpell = class;
  TFreezeWaterTE = class;
  TFreezeWater = class;
  TFireBarrierTE = class;
  TFireBarrier = class;
  TLevelTerrainTE = class;
  TLevelTerrain = class;
  TRejuvenateTE = class;
  TRejuvenate = class;
  TWatcherEnchantment = class;
  TWatcherHS = class;
  TWatcherTE = class;
  TWatcher = class;
  TTornadoTE = class;
  TTornado = class;
  TVortexTE = class;
  TVortex = class;
  THealingShowersTE = class;
  THealingShowers = class;
  TSmokeCloudSpell = class;


  { TGlobalTargetSpellTE (instance size 36, VMT 5579CBAC) }
  TGlobalTargetSpellTE = class(TSpellTE)
  public
    F_GlobalTargetSpellTE_20: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure SetLocation(A1: Byte; A2: Byte; A3: Integer);  { draft }
    procedure PlayDefaultEffects(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;

  { TGlobalTargetSpell (instance size 60, VMT 5579CC9C) }
  TGlobalTargetSpell = class(TSpell)
  public
    F_GlobalTargetSpell_34: Integer;
    F_GlobalTargetSpell_38: Byte;
    F_GlobalTargetSpell_39: Byte;
    F_GlobalTargetSpell_3A: array[0..1] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CanActivate(A1: Integer; A2: Integer); override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure ShowTargetSelection(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); virtual;  { +09C draft }
    procedure OnTargetSelectionChange(A1: Integer); virtual;  { +0A0 draft }
    procedure SetupTargetSelection(A1: Integer; A2: Integer); virtual;  { +0A4 draft }
    procedure TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +0A8 draft }
    procedure ValidTargetSelection(A1: Integer); virtual;  { +0AC draft }
    procedure ValidTargetSelectionMapF(A1: Integer); virtual;  { +0B0 draft }
    procedure ValidTargetMapF(A1: Integer); virtual;  { +0B4 draft }
  end;

  { TFreezeWaterTE (instance size 36, VMT 5579CDE0) }
  TFreezeWaterTE = class(TGlobalTargetSpellTE)
  public
    class function ClassID: Integer; override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure ChangeTerrain(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure TerrainChanged(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;

  { TFreezeWater (instance size 60, VMT 5579CEC0) }
  TFreezeWater = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: Integer; A2: Integer); override;
    procedure TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ValidTargetSelectionMapF(A1: Integer); override;
    procedure ValidTargetMapF(A1: Integer); override;
  end;

  { TFireBarrierTE (instance size 36, VMT 5579CFFC) }
  TFireBarrierTE = class(TGlobalTargetSpellTE)
  public
    class function ClassID: Integer; override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure CreateFireBarrier;  { draft }
  end;

  { TFireBarrier (instance size 60, VMT 5579D0DC) }
  TFireBarrier = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: Integer; A2: Integer); override;
    procedure TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ValidTargetSelectionMapF(A1: Integer); override;
    procedure ValidTargetMapF(A1: Integer); override;
  end;

  { TLevelTerrainTE (instance size 36, VMT 5579D218) }
  TLevelTerrainTE = class(TGlobalTargetSpellTE)
  public
    class function ClassID: Integer; override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure LevelTerrain;  { draft }
  end;

  { TLevelTerrain (instance size 60, VMT 5579D2F8) }
  TLevelTerrain = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: Integer; A2: Integer); override;
    procedure TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ValidTargetSelectionMapF(A1: Integer); override;
    procedure ValidTargetMapF(A1: Integer); override;
  end;

  { TRejuvenateTE (instance size 36, VMT 5579D434) }
  TRejuvenateTE = class(TGlobalTargetSpellTE)
  public
    class function ClassID: Integer; override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure RejuvenateTerrain(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;

  { TRejuvenate (instance size 60, VMT 5579D514) }
  TRejuvenate = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: Integer; A2: Integer); override;
    procedure TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ValidTargetSelectionMapF(A1: Integer); override;
    procedure ValidTargetMapF(A1: Integer); override;
  end;

  { TWatcherEnchantment (instance size 40, VMT 5579D648) }
  TWatcherEnchantment = class(TGlobalEnchantment)
  public
    F_WatcherEnchantment_24: Integer;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetName(A1: Integer); override;
    procedure GetLocation(A1: Integer; A2: Integer); override;
    procedure Deactivate(A1: Byte); override;
  end;

  { TWatcherHS (instance size 32, VMT 5579D7A0) }
  TWatcherHS = class(TSingleHS)
  public
    F_WatcherHS_0C: Byte;
    F_WatcherHS_0D: Byte;
    F_WatcherHS_0E: array[0..1] of Byte;
    F_WatcherHS_10: Integer;
    F_WatcherHS_14: Integer;
    F_WatcherHS_18: Integer;
    F_WatcherHS_1C: Byte;
    F_WatcherHS_1D: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetLevel: Byte; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    function PlaceOnMap: Boolean; override;
    procedure RemoveFromMap; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    procedure StartAnimation(A1: Byte; A2: Byte; A3: Integer);  { draft }
    procedure StopAnimation;  { draft }
    procedure UpdateExploration;  { draft }
    procedure UpdateUnfog;  { draft }
    procedure VisibilityRange;  { draft }
    procedure UpdateVisibleForSeatedPlayer;  { draft }
  end;

  { TWatcherTE (instance size 36, VMT 5579D92C) }
  TWatcherTE = class(TGlobalTargetSpellTE)
  public
    class function ClassID: Integer; override;
    procedure Process(A1: Integer; A2: Integer); override;
  end;

  { TWatcher (instance size 60, VMT 5579DA04) }
  TWatcher = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: Integer; A2: Integer); override;
    procedure TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

  { TTornadoTE (instance size 48, VMT 5579DB38) }
  TTornadoTE = class(TGlobalTargetSpellTE)
  public
    F_TornadoTE_24: Integer;
    F_TornadoTE_28: Integer;
    F_TornadoTE_2C: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Validate(A1: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
  end;

  { TTornado (instance size 60, VMT 5579DC10) }
  TTornado = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: Integer; A2: Integer); override;
    procedure TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ValidWarpLocation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure CalculateWarpLocation(A1: Integer; A2: Integer);  { draft }
  end;

  { TVortexTE (instance size 48, VMT 5579DD44) }
  TVortexTE = class(TGlobalTargetSpellTE)
  public
    F_VortexTE_24: Integer;
    F_VortexTE_28: Integer;
    F_VortexTE_2C: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Validate(A1: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
  end;

  { TVortex (instance size 60, VMT 5579DE1C) }
  TVortex = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: Integer; A2: Integer); override;
    procedure TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ValidTargetSelection(A1: Integer); override;
    procedure ValidateTargetEvent(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
  end;

  { THealingShowersTE (instance size 40, VMT 5579DF48) }
  THealingShowersTE = class(TGlobalTargetSpellTE)
  public
    F_HealingShowersTE_24: Integer;
    class function ClassID: Integer; override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure ChangeTerrain(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;

  { THealingShowers (instance size 60, VMT 5579E030) }
  THealingShowers = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: Integer; A2: Integer); override;
    procedure TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ValidTargetSelectionMapF(A1: Integer); override;
    procedure ValidTargetMapF(A1: Integer); override;
  end;

  { TSmokeCloudSpell (instance size 60, VMT 5579E16C) }
  TSmokeCloudSpell = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ExecuteTE(A1: Integer; A2: Integer; A3: Integer); override;
    procedure SetupTargetSelection(A1: Integer; A2: Integer); override;
    procedure TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ValidTargetSelectionMapF(A1: Integer); override;
    procedure ValidTargetMapF(A1: Integer); override;
  end;

procedure RegisterGlobalTargetSpells(A1: Integer);  { draft }
procedure UnregisterGlobalTargetSpells(A1: Integer);  { draft }

implementation

class function TGlobalTargetSpellTE.ClassID: Integer;
begin Result := 0; end;

procedure TGlobalTargetSpellTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TGlobalTargetSpellTE.SetLocation(A1: Byte; A2: Byte; A3: Integer);
begin end;

procedure TGlobalTargetSpellTE.PlayDefaultEffects(A1: Integer; A2: Integer; A3: Integer);
begin end;

constructor TGlobalTargetSpell.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TGlobalTargetSpell.ShowTargetSelection(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TGlobalTargetSpell.ValidTargetMapF(A1: Integer);
begin end;

procedure TGlobalTargetSpell.ValidTargetSelectionMapF(A1: Integer);
begin end;

procedure TGlobalTargetSpell.ValidTargetSelection(A1: Integer);
begin end;

procedure TGlobalTargetSpell.OnTargetSelectionChange(A1: Integer);
begin end;

procedure TGlobalTargetSpell.SetupTargetSelection(A1: Integer; A2: Integer);
begin end;

procedure TGlobalTargetSpell.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TGlobalTargetSpell.CanActivate(A1: Integer; A2: Integer);
begin end;

procedure TGlobalTargetSpell.Activate(A1: Integer; A2: Integer);
begin end;

class function TFreezeWaterTE.ClassID: Integer;
begin Result := 0; end;

procedure TFreezeWaterTE.ChangeTerrain(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TFreezeWaterTE.TerrainChanged(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TFreezeWaterTE.Process(A1: Integer; A2: Integer);
begin end;

constructor TFreezeWater.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TFreezeWater.ValidTargetMapF(A1: Integer);
begin end;

procedure TFreezeWater.ValidTargetSelectionMapF(A1: Integer);
begin end;

procedure TFreezeWater.SetupTargetSelection(A1: Integer; A2: Integer);
begin end;

procedure TFreezeWater.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

class function TFireBarrierTE.ClassID: Integer;
begin Result := 0; end;

procedure TFireBarrierTE.CreateFireBarrier;
begin end;

procedure TFireBarrierTE.Process(A1: Integer; A2: Integer);
begin end;

constructor TFireBarrier.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TFireBarrier.ValidTargetMapF(A1: Integer);
begin end;

procedure TFireBarrier.ValidTargetSelectionMapF(A1: Integer);
begin end;

procedure TFireBarrier.SetupTargetSelection(A1: Integer; A2: Integer);
begin end;

procedure TFireBarrier.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

class function TLevelTerrainTE.ClassID: Integer;
begin Result := 0; end;

procedure TLevelTerrainTE.LevelTerrain;
begin end;

procedure TLevelTerrainTE.Process(A1: Integer; A2: Integer);
begin end;

constructor TLevelTerrain.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TLevelTerrain.ValidTargetMapF(A1: Integer);
begin end;

procedure TLevelTerrain.ValidTargetSelectionMapF(A1: Integer);
begin end;

procedure TLevelTerrain.SetupTargetSelection(A1: Integer; A2: Integer);
begin end;

procedure TLevelTerrain.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

class function TRejuvenateTE.ClassID: Integer;
begin Result := 0; end;

procedure TRejuvenateTE.RejuvenateTerrain(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TRejuvenateTE.Process(A1: Integer; A2: Integer);
begin end;

constructor TRejuvenate.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TRejuvenate.ValidTargetMapF(A1: Integer);
begin end;

procedure TRejuvenate.ValidTargetSelectionMapF(A1: Integer);
begin end;

procedure TRejuvenate.SetupTargetSelection(A1: Integer; A2: Integer);
begin end;

procedure TRejuvenate.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

constructor TWatcherEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TWatcherEnchantment.GetName(A1: Integer);
begin end;

procedure TWatcherEnchantment.GetLocation(A1: Integer; A2: Integer);
begin end;

procedure TWatcherEnchantment.Deactivate(A1: Byte);
begin end;

constructor TWatcherHS.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TWatcherHS.Destroy;
begin end;

class function TWatcherHS.ClassID: Integer;
begin Result := 0; end;

function TWatcherHS.GetLevel: Byte;
begin Result := 0; end;

procedure TWatcherHS.StartAnimation(A1: Byte; A2: Byte; A3: Integer);
begin end;

procedure TWatcherHS.StopAnimation;
begin end;

procedure TWatcherHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TWatcherHS.UpdateExploration;
begin end;

procedure TWatcherHS.UpdateUnfog;
begin end;

procedure TWatcherHS.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TWatcherHS.Activate;
begin end;

procedure TWatcherHS.Deactivate;
begin end;

procedure TWatcherHS.VisibilityRange;
begin end;

function TWatcherHS.PlaceOnMap: Boolean;
begin Result := False; end;

procedure TWatcherHS.RemoveFromMap;
begin end;

procedure TWatcherHS.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin end;

procedure TWatcherHS.UpdateVisibleForSeatedPlayer;
begin end;

procedure TWatcherHS.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TWatcherHS.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

class function TWatcherTE.ClassID: Integer;
begin Result := 0; end;

procedure TWatcherTE.Process(A1: Integer; A2: Integer);
begin end;

constructor TWatcher.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TWatcher.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TWatcher.SetupTargetSelection(A1: Integer; A2: Integer);
begin end;

constructor TTornadoTE.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TTornadoTE.Destroy;
begin end;

class function TTornadoTE.ClassID: Integer;
begin Result := 0; end;

procedure TTornadoTE.Validate(A1: Integer);
begin end;

procedure TTornadoTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TTornadoTE.ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TTornadoTE.Process(A1: Integer; A2: Integer);
begin end;

constructor TTornado.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TTornado.ValidWarpLocation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TTornado.CalculateWarpLocation(A1: Integer; A2: Integer);
begin end;

procedure TTornado.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TTornado.SetupTargetSelection(A1: Integer; A2: Integer);
begin end;

constructor TVortexTE.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TVortexTE.Destroy;
begin end;

class function TVortexTE.ClassID: Integer;
begin Result := 0; end;

procedure TVortexTE.Validate(A1: Integer);
begin end;

procedure TVortexTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TVortexTE.ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TVortexTE.Process(A1: Integer; A2: Integer);
begin end;

constructor TVortex.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TVortex.ValidTargetSelection(A1: Integer);
begin end;

procedure TVortex.ValidateTargetEvent(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TVortex.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TVortex.SetupTargetSelection(A1: Integer; A2: Integer);
begin end;

class function THealingShowersTE.ClassID: Integer;
begin Result := 0; end;

procedure THealingShowersTE.ShowAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure THealingShowersTE.ChangeTerrain(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure THealingShowersTE.Process(A1: Integer; A2: Integer);
begin end;

constructor THealingShowers.Create(AOwner: Engine.TECustomNode);
begin end;

procedure THealingShowers.ValidTargetMapF(A1: Integer);
begin end;

procedure THealingShowers.ValidTargetSelectionMapF(A1: Integer);
begin end;

procedure THealingShowers.SetupTargetSelection(A1: Integer; A2: Integer);
begin end;

procedure THealingShowers.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

constructor TSmokeCloudSpell.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TSmokeCloudSpell.ValidTargetMapF(A1: Integer);
begin end;

procedure TSmokeCloudSpell.ValidTargetSelectionMapF(A1: Integer);
begin end;

procedure TSmokeCloudSpell.SetupTargetSelection(A1: Integer; A2: Integer);
begin end;

procedure TSmokeCloudSpell.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TSmokeCloudSpell.ExecuteTE(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure RegisterGlobalTargetSpells(A1: Integer);
begin end;

procedure UnregisterGlobalTargetSpells(A1: Integer);
begin end;


initialization
finalization

end.
