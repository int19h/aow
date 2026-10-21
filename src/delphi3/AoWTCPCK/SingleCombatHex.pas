unit SingleCombatHex;

{ Draft declarations of SingleCombatHex, from AoWTCPCK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TSingleCombatHexagon = class;
  TSingleCombatHexagonResource = class;


  { TSingleCombatHexagon (instance size 16, VMT 00434E38) }
  TSingleCombatHexagon = class(TAbstractHexagon)
  public
    class function ClassID: Integer; override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    function GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList; override;
  end;

  { TSingleCombatHexagonResource (instance size 52, VMT 00434FE8) }
  TSingleCombatHexagonResource = class(TAbstractHexagonResource)
  public
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
    procedure SetLevel(Value: Byte); override;
    function GetHexagonControl: HSEngine.THexagonControl; override;
  end;

procedure RegisterSingleCombatHexagon(A1: Integer);  { draft }

implementation

class function TSingleCombatHexagon.ClassID: Integer;
begin Result := 0; end;

function TSingleCombatHexagon.GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TSingleCombatHexagon.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

class function TSingleCombatHexagonResource.ClassID: Integer;
begin Result := 0; end;

class function TSingleCombatHexagonResource.ResourceEditName: string;
begin Result := ''; end;

procedure TSingleCombatHexagonResource.SetLevel(Value: Byte);
begin end;

function TSingleCombatHexagonResource.GetHexagonControl: HSEngine.THexagonControl;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TSingleCombatHexagonResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

function TSingleCombatHexagonResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterSingleCombatHexagon(A1: Integer);
begin end;


initialization
finalization

end.
