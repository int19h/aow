unit CombatStructure;

{ Draft declarations of CombatStructure, from AoWTCPCK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, CombatILTer;

type
  TCombatStructure = class;
  TCombatStructureResource = class;


  { TCombatStructure (instance size 40, VMT 0043258C) }
  TCombatStructure = class(TCombatFixedILTerrain)
  public
    F_CombatStructure_20: Integer;
    F_CombatStructure_24: Byte;
    F_CombatStructure_25: array[0..2] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetOverlay(Index: Integer): Shortint; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult); override;
    procedure Activate; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    function CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean; override;
    function CanPlaceOnHS(HS: HSEngine.THexagonSprite): Boolean; override;
    function ValidTerrainType(TerrainType: Integer): Boolean; override;
    function GetTerrainTypeImage(TerrainType: Integer): Integer; override;
    procedure ShowShadow(A1: Integer; A2: Integer; A3: Integer); override;
    procedure SetHitPoints(A1: Integer);  { draft }
  end;

  { TCombatStructureResource (instance size 72, VMT 00432750) }
  TCombatStructureResource = class(TCombatFixedILTerrainResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;


implementation

constructor TCombatStructure.Create(AOwner: Engine.TECustomNode);
begin end;

class function TCombatStructure.ClassID: Integer;
begin Result := 0; end;

procedure TCombatStructure.Activate;
begin end;

procedure TCombatStructure.SetHitPoints(A1: Integer);
begin end;

procedure TCombatStructure.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

procedure TCombatStructure.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin end;

procedure TCombatStructure.CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult);
begin end;

function TCombatStructure.GetOverlay(Index: Integer): Shortint;
begin Result := 0; end;

function TCombatStructure.GetTerrainTypeImage(TerrainType: Integer): Integer;
begin Result := 0; end;

procedure TCombatStructure.ShowShadow(A1: Integer; A2: Integer; A3: Integer);
begin end;

function TCombatStructure.ValidTerrainType(TerrainType: Integer): Boolean;
begin Result := False; end;

function TCombatStructure.CanPlaceOnHS(HS: HSEngine.THexagonSprite): Boolean;
begin Result := False; end;

function TCombatStructure.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
begin Result := False; end;

class function TCombatStructureResource.ClassID: Integer;
begin Result := 0; end;

class function TCombatStructureResource.ResourceEditName: string;
begin Result := ''; end;

function TCombatStructureResource.ResourceUserClassID: Integer;
begin Result := 0; end;


initialization
finalization

end.
