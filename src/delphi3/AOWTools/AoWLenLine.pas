unit AoWLenLine;

{ Draft declarations of AoWLenLine, from AOWTools.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWControl;

type
  TAoWLenLine = class;


  { TAoWLenLine (instance size 280, VMT 597052BC) }
  TAoWLenLine = class(TAOWControl)
  public
    F_AoWLenLine_114: array[0..3] of Byte;
    procedure Validate; override;
    procedure SetSize; override;
    procedure Draw(SurfDesc: GFXE.TSurfaceDesc); override;
    procedure CheckMouseDown(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure CheckMouseUp(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure CheckMouseMove(Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure CheckKeyPress(var Key: Char); override;
    procedure SetILLine(A1: Integer); virtual;  { +098 draft }
  end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);  { draft }

implementation

procedure TAoWLenLine.Validate;
begin end;

procedure TAoWLenLine.SetSize;
begin end;

procedure TAoWLenLine.SetILLine(A1: Integer);
begin end;

procedure TAoWLenLine.Draw(SurfDesc: GFXE.TSurfaceDesc);
begin end;

procedure TAoWLenLine.CheckMouseDown(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin end;

procedure TAoWLenLine.CheckMouseUp(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin end;

procedure TAoWLenLine.CheckMouseMove(Shift: Classes.TShiftState; X, Y: Integer);
begin end;

procedure TAoWLenLine.CheckKeyPress(var Key: Char);
begin end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);
begin end;


initialization
finalization

end.
