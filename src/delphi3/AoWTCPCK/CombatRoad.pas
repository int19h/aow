unit CombatRoad;

{ Draft declarations of CombatRoad, from AoWTCPCK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TCombatRoad = class;
  TCombatRoadResource = class;


  { TCombatRoad (instance size 24, VMT 00410C0C) }
  TCombatRoad = class(TAbstractRoad)
  public
    F_CombatRoad_10: Byte;
    F_CombatRoad_11: array[0..6] of Byte;
    class function ClassID: Integer; override;
    procedure NeighbourTerrainChanged(HN: Integer; const Msg: HSEngine.THSTerrainInfo); override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure Activate; override;
    function GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList; override;
    function CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    function PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    procedure UpdateTransitions; override;
    procedure UpdateTransition(A1: Byte);  { draft }
  end;

  { TCombatRoadResource (instance size 52, VMT 00410DA0) }
  TCombatRoadResource = class(TAbstractRoadResource)
  public
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetCellImage: ImageLib.TLibraryImage; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
    function GetRoadControl: HSEngine.TRoadControl; override;
  end;

procedure RegisterCombatRoad(A1: Integer);  { draft }

implementation

class function TCombatRoad.ClassID: Integer;
begin Result := 0; end;

function TCombatRoad.GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList;
begin FillChar(Result, SizeOf(Result), 0); end;

function TCombatRoad.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin Result := False; end;

function TCombatRoad.PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin Result := False; end;

procedure TCombatRoad.UpdateTransition(A1: Byte);
begin end;

procedure TCombatRoad.UpdateTransitions;
begin end;

procedure TCombatRoad.NeighbourTerrainChanged(HN: Integer; const Msg: HSEngine.THSTerrainInfo);
begin end;

procedure TCombatRoad.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TCombatRoad.Activate;
begin end;

class function TCombatRoadResource.ClassID: Integer;
begin Result := 0; end;

class function TCombatRoadResource.ResourceEditName: string;
begin Result := ''; end;

function TCombatRoadResource.GetRoadControl: HSEngine.TRoadControl;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TCombatRoadResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

function TCombatRoadResource.ResourceUserClassID: Integer;
begin Result := 0; end;

function TCombatRoadResource.GetCellImage: ImageLib.TLibraryImage;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure RegisterCombatRoad(A1: Integer);
begin end;


initialization
finalization

end.
