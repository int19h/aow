unit Str2Clip;

{ Draft declarations of Str2Clip, from ILToolsP.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;



function CopyStreamToClipboard(A1: Integer; A2: Integer): Integer;  { draft }
function PasteStreamFromClipboard(A1: Integer; A2: Integer): Integer;  { draft }

implementation

function CopyStreamToClipboard(A1: Integer; A2: Integer): Integer;
begin Result := 0; end;

function PasteStreamFromClipboard(A1: Integer; A2: Integer): Integer;
begin Result := 0; end;


initialization
finalization

end.
