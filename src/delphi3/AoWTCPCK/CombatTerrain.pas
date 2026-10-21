unit CombatTerrain;

{ Draft declarations of CombatTerrain, from AoWTCPCK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TCombatTerrainShadow = class;
  TCombatTerrain = class;
  TCombatTerrainResource = class;


  { TCombatTerrainShadow (instance size 12, VMT 0040FB0C) }
  TCombatTerrainShadow = class(THexagonSprite)
  public
    F_CombatTerrainShadow_08: Byte;
    F_CombatTerrainShadow_09: array[0..2] of Byte;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
  end;

  { TCombatTerrain (instance size 36, VMT 0040FCA0) }
  TCombatTerrain = class(TTerrainMO)
  public
    F_CombatTerrain_14: Integer;
    F_CombatTerrain_18: Integer;
    F_CombatTerrain_1C: Byte;
    F_CombatTerrain_1D: array[0..2] of Byte;
    F_CombatTerrain_20: Integer;
    destructor Destroy; override;
    class function ClassID: Integer; override;
    function PlaceOnMap: Boolean; override;
    procedure RemoveFromMap; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    procedure MakeVisible(VisibilityList: HSEngine.TVisibilityList); override;
    function GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList; override;
    function CanPlaceOnHS(HS: HSEngine.THexagonSprite): Boolean; override;
    procedure DestroyShadow(A1: Integer; A2: Integer);  { draft }
    procedure CreateShadow(A1: Integer; A2: Integer);  { draft }
    procedure SetHitPoints(A1: Integer);  { draft }
    procedure ShowShadow(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;

  { TCombatTerrainResource (instance size 76, VMT 0040FE54) }
  TCombatTerrainResource = class(TTerrainMOR)
  public
    F_CombatTerrainResource_48: Byte;
    F_CombatTerrainResource_49: Byte;
    F_CombatTerrainResource_4A: Byte;
    F_CombatTerrainResource_4B: Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterCombatTerrain(A1: Integer);  { draft }

implementation

function TCombatTerrainShadow.GetShowPriority: Integer;
begin Result := 0; end;

procedure TCombatTerrainShadow.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

class function TCombatTerrain.ClassID: Integer;
begin Result := 0; end;

destructor TCombatTerrain.Destroy;
begin end;

function TCombatTerrain.GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TCombatTerrain.DestroyShadow(A1: Integer; A2: Integer);
begin end;

function TCombatTerrain.CanPlaceOnHS(HS: HSEngine.THexagonSprite): Boolean;
begin Result := False; end;

procedure TCombatTerrain.CreateShadow(A1: Integer; A2: Integer);
begin end;

procedure TCombatTerrain.MakeVisible(VisibilityList: HSEngine.TVisibilityList);
begin end;

procedure TCombatTerrain.SetHitPoints(A1: Integer);
begin end;

procedure TCombatTerrain.ShowShadow(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TCombatTerrain.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

procedure TCombatTerrain.Activate;
begin end;

procedure TCombatTerrain.Deactivate;
begin end;

function TCombatTerrain.PlaceOnMap: Boolean;
begin Result := False; end;

procedure TCombatTerrain.RemoveFromMap;
begin end;

procedure TCombatTerrain.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin end;

procedure TCombatTerrain.CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult);
begin end;

class function TCombatTerrainResource.ClassID: Integer;
begin Result := 0; end;

function TCombatTerrainResource.ResourceUserClassID: Integer;
begin Result := 0; end;

class function TCombatTerrainResource.ResourceEditName: string;
begin Result := ''; end;

procedure TCombatTerrainResource.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure RegisterCombatTerrain(A1: Integer);
begin end;


initialization
finalization

end.
