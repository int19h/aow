unit Townhall;

{ Combat town hall, recovered from AoWTCPCK.dpl. }

{$O-,R+,Q+}

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

procedure RegisterTownhall(AEngine: TEngine);

implementation
uses IsoCombatHex;

class function TTownhall.ClassID: Integer;
begin Result := $220510; end;

class function TTownhallResource.ClassID: Integer;
begin Result := $220511; end;

class function TTownhallResource.ResourceEditName: string;
begin Result := 'Combat Townhall'; end;

function TTownhallResource.ResourceUserClassID: Integer;
begin Result := $220510; end;

procedure RegisterTownhall(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TTownhallResource, TTownhall]);
end;


initialization
finalization

end.
