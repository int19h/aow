unit CombatHex;

{ Draft declarations of CombatHex, from AoWTCPCK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWHex;

type
  TCombatHexagon = class;
  TCombatHexagonResource = class;
  TWaterCombatHexagon = class;
  TWaterCombatHexagonResource = class;


  { TCombatHexagon (instance size 20, VMT 0040340C) }
  TCombatHexagon = class(TAbstractHexagon)
  public
    F_CombatHexagon_10: Byte;
    F_CombatHexagon_11: array[0..2] of Byte;
    class function ClassID: Integer; override;
    procedure TerrainChanged(const Msg: HSEngine.THSTerrainInfo); override;
    procedure NeighbourTerrainChanged(HN: Integer; const Info: HSEngine.THSTerrainInfo); override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure Activate; override;
    function GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList; override;
    procedure UpdateTransitions; override;
    procedure UpdateTransition(A1: Byte);  { draft }
  end;

  { TCombatHexagonResource (instance size 56, VMT 004035A8) }
  TCombatHexagonResource = class(TAbstractHexagonResource)
  public
    F_CombatHexagonResource_34: Integer;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetCellImage: ImageLib.TLibraryImage; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
    function GetHexagonControl: HSEngine.THexagonControl; override;
  end;

  { TWaterCombatHexagon (instance size 32, VMT 004036A8) }
  TWaterCombatHexagon = class(TAoWWaterHexagon)
  public
    class function ClassID: Integer; override;
    function GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList; override;
  end;

  { TWaterCombatHexagonResource (instance size 56, VMT 00403854) }
  TWaterCombatHexagonResource = class(TAoWWaterHexagonResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
    function GetHexagonControl: HSEngine.THexagonControl; override;
  end;

procedure RegisterCombatHexagon(A1: Integer);  { draft }

implementation

class function TCombatHexagon.ClassID: Integer;
begin Result := 0; end;

function TCombatHexagon.GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TCombatHexagon.UpdateTransition(A1: Byte);
begin end;

procedure TCombatHexagon.UpdateTransitions;
begin end;

procedure TCombatHexagon.NeighbourTerrainChanged(HN: Integer; const Info: HSEngine.THSTerrainInfo);
begin end;

procedure TCombatHexagon.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TCombatHexagon.Activate;
begin end;

procedure TCombatHexagon.TerrainChanged(const Msg: HSEngine.THSTerrainInfo);
begin end;

class function TCombatHexagonResource.ClassID: Integer;
begin Result := 0; end;

class function TCombatHexagonResource.ResourceEditName: string;
begin Result := ''; end;

function TCombatHexagonResource.GetHexagonControl: HSEngine.THexagonControl;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TCombatHexagonResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

function TCombatHexagonResource.ResourceUserClassID: Integer;
begin Result := 0; end;

function TCombatHexagonResource.GetCellImage: ImageLib.TLibraryImage;
begin FillChar(Result, SizeOf(Result), 0); end;

function TWaterCombatHexagon.GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList;
begin FillChar(Result, SizeOf(Result), 0); end;

class function TWaterCombatHexagon.ClassID: Integer;
begin Result := 0; end;

class function TWaterCombatHexagonResource.ClassID: Integer;
begin Result := 0; end;

class function TWaterCombatHexagonResource.ResourceEditName: string;
begin Result := ''; end;

function TWaterCombatHexagonResource.ResourceUserClassID: Integer;
begin Result := 0; end;

function TWaterCombatHexagonResource.GetHexagonControl: HSEngine.THexagonControl;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure RegisterCombatHexagon(A1: Integer);
begin end;


initialization
finalization

end.
