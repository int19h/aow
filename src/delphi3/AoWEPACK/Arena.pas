unit Arena;

{ Draft declarations of Arena, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EventLog;

type
  TArenaTE = class;
  TArena = class;
  TArenaResource = class;
  TEnterArenaEventLog = class;


  { TArenaTE (instance size 44, VMT 557D6180) }
  TArenaTE = class(TStructureTE)
  public
    F_ArenaTE_28: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
  end;

  { TArena (instance size 48, VMT 557D6240) }
  TArena = class(TStructure)
  public
    class function ClassID: Integer; override;
    procedure CreateTE; override;
    procedure ExecuteTE(A1: Integer; A2: Integer); override;
    function CanDblClick: Boolean; override;
    procedure UnitTrainCost(A1: Integer);  { draft }
    procedure ExecuteTrainUnit(A1: Integer);  { draft }
    procedure CanTrainUnits(A1: Byte; A2: Integer);  { draft }
    procedure TrainUnits(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure CanEnter(A1: Integer);  { draft }
    procedure Enter(A1: Integer; A2: Integer);  { draft }
  end;

  { TArenaResource (instance size 100, VMT 557D6498) }
  TArenaResource = class(TStructureResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TEnterArenaEventLog (instance size 36, VMT 557D658C) }
  TEnterArenaEventLog = class(TEventLog)
  public
    F_EnterArenaEventLog_18: Byte;
    F_EnterArenaEventLog_19: array[0..2] of Byte;
    F_EnterArenaEventLog_1C: Byte;
    F_EnterArenaEventLog_1D: Byte;
    F_EnterArenaEventLog_1E: array[0..1] of Byte;
    F_EnterArenaEventLog_20: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetCount;  { draft }
    procedure GetUnit(A1: Integer);  { draft }
    procedure SetSelection(A1: Byte);  { draft }
    procedure Train(A1: Integer; A2: Integer);  { draft }
    procedure CanTrain(A1: Integer; A2: Integer);  { draft }
    procedure GetSelectionInfo(A1: Integer);  { draft }
  end;

procedure RegisterArena;  { draft }

implementation

constructor TArenaTE.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TArenaTE.Destroy;
begin end;

class function TArenaTE.ClassID: Integer;
begin Result := 0; end;

procedure TArenaTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

class function TArena.ClassID: Integer;
begin Result := 0; end;

function TArena.CanDblClick: Boolean;
begin end;

procedure TArena.UnitTrainCost(A1: Integer);
begin end;

procedure TArena.ExecuteTrainUnit(A1: Integer);
begin end;

procedure TArena.ExecuteTE(A1: Integer; A2: Integer);
begin end;

procedure TArena.CanTrainUnits(A1: Byte; A2: Integer);
begin end;

procedure TArena.TrainUnits(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TArena.CreateTE;
begin end;

procedure TArena.CanEnter(A1: Integer);
begin end;

procedure TArena.Enter(A1: Integer; A2: Integer);
begin end;

constructor TArenaResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TArenaResource.ResourceEditName: string;
begin Result := ''; end;

class function TArenaResource.ClassID: Integer;
begin Result := 0; end;

function TArenaResource.ResourceUserClassID: Integer;
begin Result := 0; end;

constructor TEnterArenaEventLog.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TEnterArenaEventLog.Destroy;
begin end;

procedure TEnterArenaEventLog.GetCount;
begin end;

procedure TEnterArenaEventLog.GetUnit(A1: Integer);
begin end;

procedure TEnterArenaEventLog.SetSelection(A1: Byte);
begin end;

procedure TEnterArenaEventLog.Train(A1: Integer; A2: Integer);
begin end;

procedure TEnterArenaEventLog.CanTrain(A1: Integer; A2: Integer);
begin end;

procedure TEnterArenaEventLog.GetSelectionInfo(A1: Integer);
begin end;

procedure RegisterArena;
begin end;


initialization
finalization

end.
