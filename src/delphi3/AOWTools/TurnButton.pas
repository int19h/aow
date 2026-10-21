unit TurnButton;

{ Draft declarations of TurnButton, from AOWTools.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWControl;

type
  TAOWTurnButton = class;

  TButtonType = (btText, btIcon);  { ot=1 }

  { TAOWTurnButton (instance size 324, VMT 59704A68) }
  TAOWTurnButton = class(TAOWControl)
  public
    F_AOWTurnButton_114: array[0..15] of Byte;
    F_AOWTurnButton_124: Integer;
    F_AOWTurnButton_128: Integer;
    F_AOWTurnButton_12C: array[0..3] of Byte;
    F_AOWTurnButton_130: Integer;
    F_AOWTurnButton_134: array[0..3] of Byte;
    F_AOWTurnButton_138: Integer;
    F_AOWTurnButton_13C: array[0..3] of Byte;
    F_AOWTurnButton_140: Integer;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure Validate; override;
    procedure SetSize; override;
    procedure Update; override;
    procedure Draw(SurfDesc: GFXE.TSurfaceDesc); override;
    procedure CheckMouseDown(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure CheckMouseUp(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure CheckMouseMove(Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure SetILB(A1: Integer); virtual;  { +098 draft }
  end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);  { draft }

implementation

constructor TAOWTurnButton.Create(AOwner: Classes.TComponent);
begin end;

procedure TAOWTurnButton.Validate;
begin end;

procedure TAOWTurnButton.SetSize;
begin end;

procedure TAOWTurnButton.SetILB(A1: Integer);
begin end;

procedure TAOWTurnButton.Update;
begin end;

procedure TAOWTurnButton.Draw(SurfDesc: GFXE.TSurfaceDesc);
begin end;

procedure TAOWTurnButton.CheckMouseDown(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin end;

procedure TAOWTurnButton.CheckMouseUp(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin end;

procedure TAOWTurnButton.CheckMouseMove(Shift: Classes.TShiftState; X, Y: Integer);
begin end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);
begin end;


initialization
finalization

end.
