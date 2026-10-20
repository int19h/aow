unit ReflectingPool;

{ Draft declarations of ReflectingPool, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TReflectingPool = class;
  TReflectingPoolResource = class;


  { TReflectingPool (instance size 64, VMT 557D48C8) }
  TReflectingPool = class(TPlayerStructure)
  public
    F_ReflectingPool_3C: array[0..3] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure SetPlayer(A1: Integer; A2: Integer); override;
    procedure VisibilityRange; override;
    procedure UpdateUnfog; override;
    procedure UpdateExploration; override;
    procedure GetDefaultAITargetPriority; override;
    procedure ListReflectingPools(A1: Integer);  { draft }
    procedure NewFrame(A1: Integer; A2: Integer);  { draft }
    procedure ActivatePoolCentering;  { draft }
    procedure DeactivatePoolCentering;  { draft }
    procedure UpdateReflectingPoolsExploration;  { draft }
    procedure PoolVisionPlayer(A1: Byte; A2: Integer);  { draft }
    procedure NotifyPlayerChanged(A1: Integer; A2: Integer);  { draft }
  end;

  { TReflectingPoolResource (instance size 116, VMT 557D4B6C) }
  TReflectingPoolResource = class(TPlayerStructureResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterReflectingPool;  { draft }

implementation

constructor TReflectingPool.Create(AOwner: Engine.TECustomNode);
begin end;

class function TReflectingPool.ClassID: Integer;
begin Result := 0; end;

procedure TReflectingPool.ListReflectingPools(A1: Integer);
begin end;

procedure TReflectingPool.VisibilityRange;
begin end;

procedure TReflectingPool.GetDefaultAITargetPriority;
begin end;

procedure TReflectingPool.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TReflectingPool.Activate;
begin end;

procedure TReflectingPool.Deactivate;
begin end;

procedure TReflectingPool.NewFrame(A1: Integer; A2: Integer);
begin end;

procedure TReflectingPool.ActivatePoolCentering;
begin end;

procedure TReflectingPool.DeactivatePoolCentering;
begin end;

procedure TReflectingPool.SetPlayer(A1: Integer; A2: Integer);
begin end;

procedure TReflectingPool.UpdateExploration;
begin end;

procedure TReflectingPool.UpdateReflectingPoolsExploration;
begin end;

procedure TReflectingPool.UpdateUnfog;
begin end;

procedure TReflectingPool.PoolVisionPlayer(A1: Byte; A2: Integer);
begin end;

procedure TReflectingPool.NotifyPlayerChanged(A1: Integer; A2: Integer);
begin end;

procedure TReflectingPool.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

constructor TReflectingPoolResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TReflectingPoolResource.ResourceEditName: string;
begin Result := ''; end;

class function TReflectingPoolResource.ClassID: Integer;
begin Result := 0; end;

function TReflectingPoolResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterReflectingPool;
begin end;


initialization
finalization

end.
