unit CityWall;

{ Draft declarations of CityWall, from AoWTCPCK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, CombatILTer;

type
  TCityWall = class;
  TCityWallResource = class;
  TCityWallDoor = class;
  TCityWallDoorResource = class;


  { TCityWall (instance size 48, VMT 00405008) }
  TCityWall = class(TCombatILTerrain)
  public
    F_CityWall_20: Integer;
    F_CityWall_24: Integer;
    F_CityWall_28: Integer;
    F_CityWall_2C: Byte;
    F_CityWall_2D: Byte;
    F_CityWall_2E: array[0..1] of Byte;
    class function ClassID: Integer; override;
    function GetOverlay(Index: Integer): Shortint; override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult); override;
    function CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer; override;
    procedure Activate; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    function ValidTerrainType(TerrainType: Integer): Boolean; override;
    function GetTerrainTypeImage(TerrainType: Integer): Integer; override;
    procedure ShowShadow(A1: Integer; A2: Integer; A3: Integer); override;
    function GetDirection: Integer;  { draft }
    function GetDefense: Integer;  { draft }
    procedure SetHitPoints(A1: Integer);  { draft }
  end;

  { TCityWallResource (instance size 76, VMT 004051B4) }
  TCityWallResource = class(TCombatILTerrainResource)
  public
    F_CityWallResource_48: Byte;
    F_CityWallResource_49: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TCityWallDoor (instance size 48, VMT 004052AC) }
  TCityWallDoor = class(TCityWall)
  public
    class function ClassID: Integer; override;
    function GetOverlay(Index: Integer): Shortint; override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult); override;
    function CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer; override;
  end;

  { TCityWallDoorResource (instance size 76, VMT 00405460) }
  TCityWallDoorResource = class(TCityWallResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterCityWall(A1: Integer);  { draft }

implementation

class function TCityWall.ClassID: Integer;
begin Result := 0; end;

procedure TCityWall.Activate;
begin end;

function TCityWall.GetDirection: Integer;
begin Result := 0; end;

function TCityWall.GetOverlay(Index: Integer): Shortint;
begin Result := 0; end;

function TCityWall.ValidTerrainType(TerrainType: Integer): Boolean;
begin Result := False; end;

function TCityWall.GetTerrainTypeImage(TerrainType: Integer): Integer;
begin Result := 0; end;

procedure TCityWall.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin end;

procedure TCityWall.CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult);
begin end;

function TCityWall.CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer;
begin Result := 0; end;

function TCityWall.GetDefense: Integer;
begin Result := 0; end;

procedure TCityWall.SetHitPoints(A1: Integer);
begin end;

procedure TCityWall.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

procedure TCityWall.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TCityWall.ShowShadow(A1: Integer; A2: Integer; A3: Integer);
begin end;

class function TCityWallResource.ClassID: Integer;
begin Result := 0; end;

procedure TCityWallResource.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

class function TCityWallResource.ResourceEditName: string;
begin Result := ''; end;

function TCityWallResource.ResourceUserClassID: Integer;
begin Result := 0; end;

class function TCityWallDoor.ClassID: Integer;
begin Result := 0; end;

procedure TCityWallDoor.CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult);
begin end;

function TCityWallDoor.CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer;
begin Result := 0; end;

function TCityWallDoor.GetOverlay(Index: Integer): Shortint;
begin Result := 0; end;

procedure TCityWallDoor.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

class function TCityWallDoorResource.ClassID: Integer;
begin Result := 0; end;

class function TCityWallDoorResource.ResourceEditName: string;
begin Result := ''; end;

function TCityWallDoorResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterCityWall(A1: Integer);
begin end;


initialization
finalization

end.
