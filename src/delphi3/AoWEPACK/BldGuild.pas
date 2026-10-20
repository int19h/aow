unit BldGuild;

{ Builders guild specialization and income total recovered from AoWEPACK.dpl.
  Inherited resource fields: $44 terrain binding, $5A rebuild gold,
  $5B rebuild days, $60 raze defender budget, $64 claimed state. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, PrdPlace;

type
  TBuildersGuild = class;
  TBuildersGuildResource = class;


  { TBuildersGuild (instance size 76, no added fields, VMT 557CA0DC) }
  TBuildersGuild = class(TProductionPlace)
  public
    class function ClassID: Integer; override;
  end;

  { TBuildersGuildResource (instance size 120, no added fields, VMT 557CA398) }
  TBuildersGuildResource = class(TProductionPlaceResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

function BuildersGuildIncome(Player: Shortint): Integer;
procedure RegisterBuildersGuild(AEngine: TEngine);

implementation

class function TBuildersGuild.ClassID: Integer;
begin Result := $2092E; end;

constructor TBuildersGuildResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FTerrainBound := True;
  FClaimed := False;
  FRazeDefenderBudget := 75;
  FRebuildGold := 25;
  FRebuildDays := 1;
end;

class function TBuildersGuildResource.ResourceEditName: string;
begin Result := AoWE.TranslateRStr(BuildersGuildRStr); end;

class function TBuildersGuildResource.ClassID: Integer;
begin Result := $2092F; end;

function TBuildersGuildResource.ResourceUserClassID: Integer;
begin Result := $2092E; end;

function BuildersGuildIncome(Player: Shortint): Integer;
var
  P: TPlayer;
  I: Integer;
  S: TPlayerStructure;
begin
  if AoWHSMap <> nil then
  begin
    P := AoWHSMap.FPlayers.GetPlayers(Player);
    Result := 0;
    for I := 0 to P.FStructures.Count - 1 do
    begin
      S := P.FStructures.GetStructure(I);
      if (S.ClassID = $2092E) and (S.FPlayer = Player) then
        Inc(Result, S.GetIncome);
    end;
  end
  else Result := -1;
end;

procedure RegisterBuildersGuild(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TBuildersGuild, TBuildersGuildResource]);
end;

initialization
finalization

end.
