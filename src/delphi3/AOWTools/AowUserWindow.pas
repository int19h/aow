unit AowUserWindow;

{ Draft declarations of AowUserWindow, from AOWTools.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWWindow;

type
  TAoWUserWindow = class;

  TDrawSurfaceExEvent = procedure(Surface: TSurface; var Handled: Boolean) of object;

  { TAoWUserWindow (instance size 500, VMT 59706628) }
  TAoWUserWindow = class(TAOWWindow)
  public
    F_AoWUserWindow_1EC: array[0..3] of Byte;
    F_AoWUserWindow_1F0: Integer;
    procedure DrawSurface(Surface: GFXE.TSurface); override;
  end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);  { draft }

implementation

procedure TAoWUserWindow.DrawSurface(Surface: GFXE.TSurface);
begin end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);
begin end;


initialization
finalization

end.
