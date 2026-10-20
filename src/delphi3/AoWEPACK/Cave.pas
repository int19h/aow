unit Cave;

{ Draft declarations of Cave, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EventLog;

type
  TCave = class;
  TCaveResource = class;
  TEnterCaveEventLog = class;

  TCaveEntrance = (ceUp, ceDown, ceIdle);  { ot=1 }

  { TCave (instance size 52, VMT 557B3018) }
  TCave = class(TStructure)
  public
    F_Cave_30: Byte;
    F_Cave_31: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetOverlay(Index: Integer): Shortint; override;
    procedure MoveExclusive(const Info: HSEngine.THSSenderInfo); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    function CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean; override;
    function PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean; override;
    function GetTerrainTypeImage(TerrainType: Integer): Integer; override;
    procedure GetTopBorderImage; override;
    procedure GetMiddleBorderImage; override;
    procedure GetBottomBorderImage; override;
    procedure ArmyPlaced(A1: Integer); override;
    procedure EnterMovePoints(A1: Integer; A2: Integer);  { draft }
    procedure CanEnterSelection(A1: Integer);  { draft }
    procedure CanEnter(A1: Integer);  { draft }
    procedure EnterEx;  { draft }
    procedure Enter(A1: Integer);  { draft }
  end;

  { TCaveResource (instance size 100, VMT 557B326C) }
  TCaveResource = class(TStructureResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TEnterCaveEventLog (instance size 44, VMT 557B335C) }
  TEnterCaveEventLog = class(TMessageEventLog)
  public
    F_EnterCaveEventLog_28: Byte;
    F_EnterCaveEventLog_29: array[0..2] of Byte;
    procedure Yes; override;
    procedure No; override;
  end;

procedure RegisterCave;  { draft }

implementation

constructor TCave.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TCave.Destroy;
begin end;

class function TCave.ClassID: Integer;
begin Result := 0; end;

procedure TCave.GetTopBorderImage;
begin end;

procedure TCave.GetMiddleBorderImage;
begin end;

procedure TCave.GetBottomBorderImage;
begin end;

function TCave.GetTerrainTypeImage(TerrainType: Integer): Integer;
begin Result := 0; end;

function TCave.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
begin Result := False; end;

function TCave.PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
begin Result := False; end;

procedure TCave.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TCave.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin end;

procedure TCave.MoveExclusive(const Info: HSEngine.THSSenderInfo);
begin end;

function TCave.GetOverlay(Index: Integer): Shortint;
begin Result := 0; end;

procedure TCave.Activate;
begin end;

procedure TCave.Deactivate;
begin end;

procedure TCave.EnterMovePoints(A1: Integer; A2: Integer);
begin end;

procedure TCave.CanEnterSelection(A1: Integer);
begin end;

procedure TCave.CanEnter(A1: Integer);
begin end;

procedure TCave.EnterEx;
begin end;

procedure TCave.Enter(A1: Integer);
begin end;

procedure TCave.ArmyPlaced(A1: Integer);
begin end;

constructor TCaveResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TCaveResource.ResourceEditName: string;
begin Result := ''; end;

class function TCaveResource.ClassID: Integer;
begin Result := 0; end;

function TCaveResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure TEnterCaveEventLog.Yes;
begin end;

procedure TEnterCaveEventLog.No;
begin end;

procedure RegisterCave;
begin end;


initialization
finalization

end.
