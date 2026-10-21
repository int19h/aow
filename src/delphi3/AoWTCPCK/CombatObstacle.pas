unit CombatObstacle;

{ Draft declarations of CombatObstacle, from AoWTCPCK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TCombatObstacleShadow = class;
  TCombatObstacleOverlay = class;
  TCombatObstacle = class;
  TCombatObstacleResource = class;


  { TCombatObstacleShadow (instance size 12, VMT 00431888) }
  TCombatObstacleShadow = class(THexagonSprite)
  public
    F_CombatObstacleShadow_08: Byte;
    F_CombatObstacleShadow_09: array[0..2] of Byte;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
  end;

  { TCombatObstacleOverlay (instance size 12, VMT 00431A20) }
  TCombatObstacleOverlay = class(THexagonSprite)
  public
    F_CombatObstacleOverlay_08: Byte;
    F_CombatObstacleOverlay_09: array[0..2] of Byte;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
  end;

  { TCombatObstacle (instance size 28, VMT 00431BB8) }
  TCombatObstacle = class(TMultiHexMO)
  public
    F_CombatObstacle_14: Integer;
    F_CombatObstacle_18: Integer;
    destructor Destroy; override;
    class function ClassID: Integer; override;
    function PlaceOnMap: Boolean; override;
    procedure RemoveFromMap; override;
    procedure CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    procedure MakeVisible(VisibilityList: HSEngine.TVisibilityList); override;
    function GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList; override;
    function CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    function PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    procedure CreateShadow(A1: Integer; A2: Integer);  { draft }
    procedure DestroyShadow(A1: Integer; A2: Integer);  { draft }
    procedure CreateOverlay(A1: Integer; A2: Integer);  { draft }
    procedure DestroyOverlay(A1: Integer; A2: Integer);  { draft }
    procedure ShowShadow(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure ShowOverlay(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;

  { TCombatObstacleResource (instance size 68, VMT 00431D60) }
  TCombatObstacleResource = class(TMultiHexMOR)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterCombatObstacle(A1: Integer);  { draft }

implementation

function TCombatObstacleShadow.GetShowPriority: Integer;
begin Result := 0; end;

procedure TCombatObstacleShadow.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

function TCombatObstacleOverlay.GetShowPriority: Integer;
begin Result := 0; end;

procedure TCombatObstacleOverlay.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

class function TCombatObstacle.ClassID: Integer;
begin Result := 0; end;

destructor TCombatObstacle.Destroy;
begin end;

function TCombatObstacle.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin Result := False; end;

function TCombatObstacle.GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList;
begin FillChar(Result, SizeOf(Result), 0); end;

function TCombatObstacle.PlaceOnMap: Boolean;
begin Result := False; end;

procedure TCombatObstacle.RemoveFromMap;
begin end;

procedure TCombatObstacle.CreateShadow(A1: Integer; A2: Integer);
begin end;

procedure TCombatObstacle.DestroyShadow(A1: Integer; A2: Integer);
begin end;

procedure TCombatObstacle.CreateOverlay(A1: Integer; A2: Integer);
begin end;

procedure TCombatObstacle.DestroyOverlay(A1: Integer; A2: Integer);
begin end;

procedure TCombatObstacle.ShowShadow(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TCombatObstacle.ShowOverlay(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TCombatObstacle.MakeVisible(VisibilityList: HSEngine.TVisibilityList);
begin end;

function TCombatObstacle.PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin Result := False; end;

procedure TCombatObstacle.Activate;
begin end;

procedure TCombatObstacle.Deactivate;
begin end;

procedure TCombatObstacle.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin end;

procedure TCombatObstacle.CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult);
begin end;

class function TCombatObstacleResource.ClassID: Integer;
begin Result := 0; end;

class function TCombatObstacleResource.ResourceEditName: string;
begin Result := ''; end;

function TCombatObstacleResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterCombatObstacle(A1: Integer);
begin end;


initialization
finalization

end.
