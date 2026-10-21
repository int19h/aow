unit AbilityP;

{ Draft declarations of AbilityP, from AbilityP.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;




function GetPackageInfoTable: Integer; { AbilityP.@GetPackageInfoTable; draft }
procedure PackageLoad; { AbilityP.@PackageLoad; draft }
procedure PackageUnload; { AbilityP.@PackageUnload; draft }

implementation

function GetPackageInfoTable: Integer;
begin Result := 0; end;

procedure PackageLoad;
begin end;

procedure PackageUnload;
begin end;



end.
