unit AoWBookWindow;

{ Draft declarations of AoWBookWindow, from AOWTools.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWWindow;

type
  TAoWBookWindow = class;


  { TAoWBookWindow (instance size 520, VMT 59705D48) }
  TAoWBookWindow = class(TAOWWindow)
  public
    F_AoWBookWindow_1EC: array[0..3] of Byte;
    F_AoWBookWindow_1F0: Integer;
    F_AoWBookWindow_1F4: Byte;
    F_AoWBookWindow_1F5: Byte;
    F_AoWBookWindow_1F6: array[0..1] of Byte;
    F_AoWBookWindow_1F8: Integer;
    F_AoWBookWindow_1FC: Byte;
    F_AoWBookWindow_1FD: array[0..2] of Byte;
    F_AoWBookWindow_200: Integer;
    F_AoWBookWindow_204: Byte;
    F_AoWBookWindow_205: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure Update; override;
    procedure SetVisible(Value: Boolean); override;
    procedure DrawSurface(Surface: GFXE.TSurface); override;
    procedure CheckMouseDown(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure CheckMouseUp(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure CheckMouseMove(Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure Blt(Surface: GFXE.TSurface); override;
    procedure StartAnim(A1: Integer);  { draft }
  end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);  { draft }

implementation

constructor TAoWBookWindow.Create(AOwner: Classes.TComponent);
begin end;

destructor TAoWBookWindow.Destroy;
begin end;

procedure TAoWBookWindow.SetVisible(Value: Boolean);
begin end;

procedure TAoWBookWindow.Update;
begin end;

procedure TAoWBookWindow.StartAnim(A1: Integer);
begin end;

procedure TAoWBookWindow.DrawSurface(Surface: GFXE.TSurface);
begin end;

procedure TAoWBookWindow.Blt(Surface: GFXE.TSurface);
begin end;

procedure TAoWBookWindow.CheckMouseDown(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin end;

procedure TAoWBookWindow.CheckMouseUp(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin end;

procedure TAoWBookWindow.CheckMouseMove(Shift: Classes.TShiftState; X, Y: Integer);
begin end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);
begin end;


initialization
finalization

end.
