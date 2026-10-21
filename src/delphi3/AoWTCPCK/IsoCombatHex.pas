unit IsoCombatHex;

{ Draft declarations of IsoCombatHex, from AoWTCPCK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TIsometricCombatHexagon = class;
  TIsometricCombatHexagonResource = class;


  { TIsometricCombatHexagon (instance size 24, VMT 0043386C) }
  TIsometricCombatHexagon = class(TUpperIsometricHexagon)
  public
    class function ClassID: Integer; override;
    function GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList; override;
    procedure ShowDynamic(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
  end;

  { TIsometricCombatHexagonResource (instance size 56, VMT 00433A24) }
  TIsometricCombatHexagonResource = class(TUpperIsometricHexagonResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
    function GetHexagonControl: HSEngine.THexagonControl; override;
  end;

procedure RegisterIsometricCombatHexagon(A1: Integer);  { draft }

implementation

class function TIsometricCombatHexagon.ClassID: Integer;
begin Result := 0; end;

function TIsometricCombatHexagon.GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TIsometricCombatHexagon.ShowDynamic(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

class function TIsometricCombatHexagonResource.ClassID: Integer;
begin Result := 0; end;

class function TIsometricCombatHexagonResource.ResourceEditName: string;
begin Result := ''; end;

function TIsometricCombatHexagonResource.ResourceUserClassID: Integer;
begin Result := 0; end;

function TIsometricCombatHexagonResource.GetHexagonControl: HSEngine.THexagonControl;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure RegisterIsometricCombatHexagon(A1: Integer);
begin end;


initialization
finalization

end.
