unit StartMenu;

{ Draft declarations of StartMenu, from AOWTools.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AOWMenu;

type
  TStartMenu = class;


  { TStartMenu (instance size 600, VMT 597042FC) }
  TStartMenu = class(TAOWMenu)
  public
    F_StartMenu_254: array[0..3] of Byte;
    procedure SetSize; override;
    procedure SetVisible(Value: Boolean); override;
    procedure Draw(SurfDesc: GFXE.TSurfaceDesc); override;
    procedure CheckMouseDown(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer); override;
  end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);  { draft }

implementation

procedure TStartMenu.SetSize;
begin end;

procedure TStartMenu.SetVisible(Value: Boolean);
begin end;

procedure TStartMenu.Draw(SurfDesc: GFXE.TSurfaceDesc);
begin end;

procedure TStartMenu.CheckMouseDown(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);
begin end;


initialization
finalization

end.
