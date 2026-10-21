unit MainStructure;

{ Draft declarations of MainStructure, from AoWTCPCK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, CombatStructure;

type
  TMainStructure = class;
  TMainStructureResource = class;


  { TMainStructure (instance size 40, VMT 00435310) }
  TMainStructure = class(TCombatStructure)
  public
    class function ClassID: Integer; override;
    function GetTerrainTypeImage(TerrainType: Integer): Integer; override;
  end;

  { TMainStructureResource (instance size 72, VMT 004354CC) }
  TMainStructureResource = class(TCombatStructureResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterMainStructure(A1: Integer);  { draft }

implementation

class function TMainStructure.ClassID: Integer;
begin Result := 0; end;

function TMainStructure.GetTerrainTypeImage(TerrainType: Integer): Integer;
begin Result := 0; end;

class function TMainStructureResource.ClassID: Integer;
begin Result := 0; end;

class function TMainStructureResource.ResourceEditName: string;
begin Result := ''; end;

function TMainStructureResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterMainStructure(A1: Integer);
begin end;


initialization
finalization

end.
