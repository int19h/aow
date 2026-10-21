unit CombatILTer;

{ Draft declarations of CombatILTer, from AoWTCPCK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TCombatILTerrainShadow = class;
  TCombatILTerrain = class;
  TCombatILTerrainResource = class;
  TCombatFixedILTerrain = class;
  TCombatFixedILTerrainResource = class;


  { TCombatILTerrainShadow (instance size 12, VMT 004041E4) }
  TCombatILTerrainShadow = class(THexagonSprite)
  public
    F_CombatILTerrainShadow_08: Byte;
    F_CombatILTerrainShadow_09: array[0..2] of Byte;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
  end;

  { TCombatILTerrain (instance size 32, VMT 00404378) }
  TCombatILTerrain = class(TILTerrainMO)
  public
    F_CombatILTerrain_1C: Integer;
    destructor Destroy; override;
    class function ClassID: Integer; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure MakeVisible(VisibilityList: HSEngine.TVisibilityList); override;
    function GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList; override;
    function CanPlaceOnHS(HS: HSEngine.THexagonSprite): Boolean; override;
    procedure ShowShadow(A1: Integer; A2: Integer; A3: Integer); virtual;  { +138 draft }
    function GetDefense: Integer;  { draft }
    function GetBurnValue: Integer;  { draft }
    procedure DestroyShadow(A1: Integer; A2: Integer);  { draft }
    procedure CreateShadow(A1: Integer; A2: Integer);  { draft }
  end;

  { TCombatILTerrainResource (instance size 72, VMT 00404538) }
  TCombatILTerrainResource = class(TILTerrainMOR)
  public
    F_CombatILTerrainResource_44: Byte;
    F_CombatILTerrainResource_45: Byte;
    F_CombatILTerrainResource_46: array[0..1] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TCombatFixedILTerrain (instance size 32, VMT 00404644) }
  TCombatFixedILTerrain = class(TCombatILTerrain)
  public
    class function ClassID: Integer; override;
    function CanChangeTerrain(const Info: HSEngine.THSSenderInfo): Boolean; override;
    procedure ChangeTerrain(const Info: HSEngine.THSTerrainInfo); override;
    procedure TerrainChanged(const Info: HSEngine.THSTerrainInfo); override;
    function ForceTerrainType(MapLevel: HSEngine.TMapLevel; Xhx, Yhx: ShortInt): ShortInt; override;
  end;

  { TCombatFixedILTerrainResource (instance size 72, VMT 0040480C) }
  TCombatFixedILTerrainResource = class(TCombatILTerrainResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterCombatILTerrain(A1: Integer);  { draft }

implementation

function TCombatILTerrainShadow.GetShowPriority: Integer;
begin Result := 0; end;

procedure TCombatILTerrainShadow.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

function TCombatILTerrain.GetDefense: Integer;
begin Result := 0; end;

function TCombatILTerrain.GetBurnValue: Integer;
begin Result := 0; end;

function TCombatILTerrain.CanPlaceOnHS(HS: HSEngine.THexagonSprite): Boolean;
begin Result := False; end;

destructor TCombatILTerrain.Destroy;
begin end;

class function TCombatILTerrain.ClassID: Integer;
begin Result := 0; end;

procedure TCombatILTerrain.ShowShadow(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TCombatILTerrain.DestroyShadow(A1: Integer; A2: Integer);
begin end;

procedure TCombatILTerrain.CreateShadow(A1: Integer; A2: Integer);
begin end;

procedure TCombatILTerrain.MakeVisible(VisibilityList: HSEngine.TVisibilityList);
begin end;

procedure TCombatILTerrain.Activate;
begin end;

procedure TCombatILTerrain.Deactivate;
begin end;

function TCombatILTerrain.GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TCombatILTerrain.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

class function TCombatILTerrainResource.ClassID: Integer;
begin Result := 0; end;

class function TCombatILTerrainResource.ResourceEditName: string;
begin Result := ''; end;

procedure TCombatILTerrainResource.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TCombatILTerrainResource.ResourceUserClassID: Integer;
begin Result := 0; end;

class function TCombatFixedILTerrain.ClassID: Integer;
begin Result := 0; end;

function TCombatFixedILTerrain.ForceTerrainType(MapLevel: HSEngine.TMapLevel; Xhx, Yhx: ShortInt): ShortInt;
begin Result := 0; end;

function TCombatFixedILTerrain.CanChangeTerrain(const Info: HSEngine.THSSenderInfo): Boolean;
begin Result := False; end;

procedure TCombatFixedILTerrain.ChangeTerrain(const Info: HSEngine.THSTerrainInfo);
begin end;

procedure TCombatFixedILTerrain.TerrainChanged(const Info: HSEngine.THSTerrainInfo);
begin end;

class function TCombatFixedILTerrainResource.ClassID: Integer;
begin Result := 0; end;

class function TCombatFixedILTerrainResource.ResourceEditName: string;
begin Result := ''; end;

function TCombatFixedILTerrainResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterCombatILTerrain(A1: Integer);
begin end;


initialization
finalization

end.
