unit Townhall;

{ Draft declarations of Townhall, from AoWTCPCK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, CombatStructure;

type
  TTownhall = class;
  TTownhallResource = class;


  { TTownhall (instance size 40, VMT 004341F8) }
  TTownhall = class(TCombatStructure)
  public
    class function ClassID: Integer; override;
  end;

  { TTownhallResource (instance size 72, VMT 004343A4) }
  TTownhallResource = class(TCombatStructureResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterTownhall(A1: Integer);  { draft }

implementation

class function TTownhall.ClassID: Integer;
begin Result := 0; end;

class function TTownhallResource.ClassID: Integer;
begin Result := 0; end;

class function TTownhallResource.ResourceEditName: string;
begin Result := ''; end;

function TTownhallResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterTownhall(A1: Integer);
begin end;


initialization
finalization

end.
