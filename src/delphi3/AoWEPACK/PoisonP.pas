unit PoisonP;

{ Draft declarations of PoisonP, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, GlobalTargetSpells;

type
  TPoisonPlant = class;
  TPoisonPlantResource = class;
  TPoisonPlantSpellTE = class;
  TPoisonPlantSpell = class;


  { TPoisonPlant (instance size 32, VMT 557C3AB8) }
  TPoisonPlant = class(TILTerrainMO)
  public
    F_PoisonPlant_1C: array[0..0] of Byte;
    F_PoisonPlant_1D: Byte;
    F_PoisonPlant_1E: Byte;
    F_PoisonPlant_1F: Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    function PlaceOnMap: Boolean; override;
    procedure RemoveFromMap; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    function CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    procedure PoisonPlantActive;  { draft }
    procedure CanDoDamage(A1: Integer);  { draft }
    procedure TriggerArmyDamage(A1: Integer);  { draft }
    procedure ArmyPlaced(A1: Integer);  { draft }
    procedure RestoreTerrain;  { draft }
    procedure NewTurn(A1: Integer);  { draft }
    procedure ShowSummonAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure NewFrameSummonAnimation(A1: Integer; A2: Integer);  { draft }
  end;

  { TPoisonPlantResource (instance size 68, VMT 557C3C68) }
  TPoisonPlantResource = class(TILTerrainMOR)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TPoisonPlantSpellTE (instance size 36, VMT 557C3D68) }
  TPoisonPlantSpellTE = class(TGlobalTargetSpellTE)
  public
    class function ClassID: Integer; override;
    function Process(A1: Integer; A2: Integer): Boolean; override;
    procedure CreatePoisonPlant(A1: Integer);  { draft }
  end;

  { TPoisonPlantSpell (instance size 60, VMT 557C3E48) }
  TPoisonPlantSpell = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: Integer; A2: Integer); override;
    function TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer): Boolean; override;
    function ValidTargetSelectionMapF(A1: Integer): Boolean; override;
    function ValidTargetMapF(A1: Integer): Boolean; override;
  end;

procedure RegisterPoisonPlant(A1: Integer);  { draft }
procedure UnRegisterPoisonPlant(A1: Integer);  { draft }

implementation

constructor TPoisonPlant.Create(AOwner: Engine.TECustomNode);
begin end;

class function TPoisonPlant.ClassID: Integer;
begin Result := 0; end;

procedure TPoisonPlant.PoisonPlantActive;
begin end;

procedure TPoisonPlant.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TPoisonPlant.CanDoDamage(A1: Integer);
begin end;

procedure TPoisonPlant.TriggerArmyDamage(A1: Integer);
begin end;

procedure TPoisonPlant.ArmyPlaced(A1: Integer);
begin end;

procedure TPoisonPlant.RestoreTerrain;
begin end;

procedure TPoisonPlant.NewTurn(A1: Integer);
begin end;

procedure TPoisonPlant.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin end;

function TPoisonPlant.CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer;
begin Result := 0; end;

procedure TPoisonPlant.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

function TPoisonPlant.PlaceOnMap: Boolean;
begin Result := False; end;

procedure TPoisonPlant.RemoveFromMap;
begin end;

procedure TPoisonPlant.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TPoisonPlant.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TPoisonPlant.ShowSummonAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TPoisonPlant.NewFrameSummonAnimation(A1: Integer; A2: Integer);
begin end;

class function TPoisonPlantResource.ResourceEditName: string;
begin Result := ''; end;

class function TPoisonPlantResource.ClassID: Integer;
begin Result := 0; end;

function TPoisonPlantResource.ResourceUserClassID: Integer;
begin Result := 0; end;

class function TPoisonPlantSpellTE.ClassID: Integer;
begin Result := 0; end;

procedure TPoisonPlantSpellTE.CreatePoisonPlant(A1: Integer);
begin end;

function TPoisonPlantSpellTE.Process(A1: Integer; A2: Integer): Boolean;
begin Result := False; end;

constructor TPoisonPlantSpell.Create(AOwner: Engine.TECustomNode);
begin end;

function TPoisonPlantSpell.ValidTargetMapF(A1: Integer): Boolean;
begin Result := False; end;

function TPoisonPlantSpell.ValidTargetSelectionMapF(A1: Integer): Boolean;
begin Result := False; end;

procedure TPoisonPlantSpell.SetupTargetSelection(A1: Integer; A2: Integer);
begin end;

function TPoisonPlantSpell.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer): Boolean;
begin Result := False; end;

procedure RegisterPoisonPlant(A1: Integer);
begin end;

procedure UnRegisterPoisonPlant(A1: Integer);
begin end;


initialization
finalization

end.
