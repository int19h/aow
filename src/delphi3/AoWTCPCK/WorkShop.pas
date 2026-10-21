unit WorkShop;

{ Draft declarations of WorkShop, from AoWTCPCK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, CombatStructure;

type
  TWorkshop = class;
  TWorkshopResource = class;


  { TWorkshop (instance size 40, VMT 004334E0) }
  TWorkshop = class(TCombatStructure)
  public
    class function ClassID: Integer; override;
  end;

  { TWorkshopResource (instance size 72, VMT 0043368C) }
  TWorkshopResource = class(TCombatStructureResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterWorkshop(A1: Integer);  { draft }

implementation

class function TWorkshop.ClassID: Integer;
begin Result := 0; end;

class function TWorkshopResource.ClassID: Integer;
begin Result := 0; end;

class function TWorkshopResource.ResourceEditName: string;
begin Result := ''; end;

function TWorkshopResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterWorkshop(A1: Integer);
begin end;


initialization
finalization

end.
