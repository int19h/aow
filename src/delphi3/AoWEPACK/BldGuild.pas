unit BldGuild;

{ Draft declarations of BldGuild, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, PrdPlace;

type
  TBuildersGuild = class;
  TBuildersGuildResource = class;


  { TBuildersGuild (instance size 76, VMT 557CA0DC) }
  TBuildersGuild = class(TProductionPlace)
  public
    class function ClassID: Integer; override;
  end;

  { TBuildersGuildResource (instance size 120, VMT 557CA398) }
  TBuildersGuildResource = class(TProductionPlaceResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure BuildersGuildIncome(A1: Byte);  { draft }
procedure RegisterBuildersGuild;  { draft }

implementation

class function TBuildersGuild.ClassID: Integer;
begin Result := 0; end;

constructor TBuildersGuildResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TBuildersGuildResource.ResourceEditName: string;
begin Result := ''; end;

class function TBuildersGuildResource.ClassID: Integer;
begin Result := 0; end;

function TBuildersGuildResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure BuildersGuildIncome(A1: Byte);
begin end;

procedure RegisterBuildersGuild;
begin end;


initialization
finalization

end.
