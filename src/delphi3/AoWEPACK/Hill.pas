unit Hill;

{ Draft declarations of Hill, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  THillMO = class;
  THillMOR = class;


  { THillMO (instance size 20, VMT 55800AFC) }
  THillMO = class(TTerrainMO)
  public
    class function ClassID: Integer; override;
  end;

  { THillMOR (instance size 72, VMT 55800C98) }
  THillMOR = class(TTerrainMOR)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function CreateResourceUser: Engine.TEObject; override;
  end;

procedure RegisterHill(A1: Integer; A2: Integer; A3: Integer);  { draft }

implementation

class function THillMO.ClassID: Integer;
begin Result := 0; end;

class function THillMOR.ClassID: Integer;
begin Result := 0; end;

class function THillMOR.ResourceEditName: string;
begin Result := ''; end;

function THillMOR.CreateResourceUser: Engine.TEObject;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure RegisterHill(A1: Integer; A2: Integer; A3: Integer);
begin end;


initialization
finalization

end.
