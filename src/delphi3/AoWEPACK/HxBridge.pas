unit HxBridge;

{ Draft declarations of HxBridge, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  THexagonBridge = class;
  THexagonBridgeResource = class;


  { THexagonBridge (instance size 28, VMT 557994E0) }
  THexagonBridge = class(TAbstractRoad)
  public
    F_HexagonBridge_10: Byte;
    F_HexagonBridge_11: array[0..2] of Byte;
    F_HexagonBridge_14: Integer;
    F_HexagonBridge_18: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetTerrain(Index: Integer): Shortint; override;
    function GetLevel: Byte; override;
    function GetShowPriority: Integer; override;
    procedure Connect; override;
    procedure Disconnect; override;
    procedure ChangeTerrain(const Msg: HSEngine.THSTerrainInfo); override;
    procedure NeighbourTerrainChanged(HN: Integer; const Msg: HSEngine.THSTerrainInfo); override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure MoveExclusive(const Info: HSEngine.THSSenderInfo); override;
    procedure Activate; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    function LinkToResource(AEngine: Engine.TEngine): Boolean; override;
    function CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    function PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    procedure UpdateTransitions; override;
    procedure DirectionValid(A1: Integer; A2: Integer);  { draft }
    procedure UpdateExclusiveMoves;  { draft }
  end;

  { THexagonBridgeResource (instance size 52, VMT 5579967C) }
  THexagonBridgeResource = class(TAbstractRoadResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterHexagonBridge;  { draft }

implementation

constructor THexagonBridge.Create(AOwner: Engine.TECustomNode);
begin end;

destructor THexagonBridge.Destroy;
begin end;

class function THexagonBridge.ClassID: Integer;
begin Result := 0; end;

function THexagonBridge.GetLevel: Byte;
begin Result := 0; end;

function THexagonBridge.LinkToResource(AEngine: Engine.TEngine): Boolean;
begin Result := False; end;

function THexagonBridge.GetTerrain(Index: Integer): Shortint;
begin Result := 0; end;

function THexagonBridge.GetShowPriority: Integer;
begin Result := 0; end;

procedure THexagonBridge.Connect;
begin end;

procedure THexagonBridge.Disconnect;
begin end;

procedure THexagonBridge.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin end;

procedure THexagonBridge.MoveExclusive(const Info: HSEngine.THSSenderInfo);
begin end;

procedure THexagonBridge.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure THexagonBridge.Activate;
begin end;

function THexagonBridge.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin Result := False; end;

function THexagonBridge.PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin Result := False; end;

procedure THexagonBridge.DirectionValid(A1: Integer; A2: Integer);
begin end;

procedure THexagonBridge.UpdateExclusiveMoves;
begin end;

procedure THexagonBridge.UpdateTransitions;
begin end;

procedure THexagonBridge.NeighbourTerrainChanged(HN: Integer; const Msg: HSEngine.THSTerrainInfo);
begin end;

procedure THexagonBridge.ChangeTerrain(const Msg: HSEngine.THSTerrainInfo);
begin end;

constructor THexagonBridgeResource.Create(AOwner: Engine.TECustomNode);
begin end;

function THexagonBridgeResource.ResourceUserClassID: Integer;
begin Result := 0; end;

class function THexagonBridgeResource.ResourceEditName: string;
begin Result := ''; end;

class function THexagonBridgeResource.ClassID: Integer;
begin Result := 0; end;

procedure RegisterHexagonBridge;
begin end;


initialization
finalization

end.
