unit House;

{ Draft declarations of House, from AoWTCPCK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, CombatStructure;

type
  THouse = class;
  THouseResource = class;


  { THouse (instance size 48, VMT 00434584) }
  THouse = class(TCombatStructure)
  public
    F_House_28: Integer;
    F_House_2C: Integer;
    class function ClassID: Integer; override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure Activate; override;
    procedure ShowShadow(A1: Integer; A2: Integer; A3: Integer); override;
  end;

  { THouseResource (instance size 72, VMT 00434728) }
  THouseResource = class(TCombatStructureResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterHouse(A1: Integer);  { draft }

implementation

class function THouse.ClassID: Integer;
begin Result := 0; end;

procedure THouse.Activate;
begin end;

procedure THouse.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure THouse.ShowShadow(A1: Integer; A2: Integer; A3: Integer);
begin end;

class function THouseResource.ClassID: Integer;
begin Result := 0; end;

class function THouseResource.ResourceEditName: string;
begin Result := ''; end;

function THouseResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterHouse(A1: Integer);
begin end;


initialization
finalization

end.
