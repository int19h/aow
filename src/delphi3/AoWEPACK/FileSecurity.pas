unit FileSecurity;

{ Draft declarations of FileSecurity, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;



procedure GetFileSecurityID(A1: Integer; A2: Integer);  { draft }
procedure SetFileSecurityID(A1: Integer; A2: Integer);  { draft }
procedure RemoveFileSecurityID;  { draft }

implementation

procedure GetFileSecurityID(A1: Integer; A2: Integer);
begin end;

procedure SetFileSecurityID(A1: Integer; A2: Integer);
begin end;

procedure RemoveFileSecurityID;
begin end;


initialization
finalization

end.
