unit AoWLenLine;

{ AoWLenLine from AOWTools.dpl: recovered from the original code and RTTI.
  Class layouts and VMT order follow the shipped module. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWControl, AOWInterfaceImgLib;

type
  TAoWLenLine = class;


  { TAoWLenLine: instance size $118; $114 vertical line image library. }
  TAoWLenLine = class(TAOWControl)
  public
    FILLine: TInterfaceIL; { $114 }
    procedure Validate; override;
    procedure SetSize; override;
    procedure Draw(SurfDesc: GFXE.TSurfaceDesc); override;
    procedure CheckMouseDown(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure CheckMouseUp(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure CheckMouseMove(Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure CheckKeyPress(var Key: Char); override;
    procedure SetILLine(Value: TInterfaceIL); virtual;
  published
    property WinHeight: Integer read FWinHeight write SetHeight;
    property ILLine: TInterfaceIL read FILLine write SetILLine;
  end;

procedure Register;

implementation

procedure TAoWLenLine.Validate;
begin
  if FILLine <> nil then FValid := True;
  inherited SetSize; { Original bug: Validate calls SetSize. }
end;

procedure TAoWLenLine.SetSize;
begin
  FWinWidth := FILLine[0].Width;
  inherited SetSize;
end;

procedure TAoWLenLine.SetILLine(Value: TInterfaceIL);
begin
  if Value <> nil then
    if Value.Count = 3 then FILLine := Value
    else MessageBox(0, 'Lines must have 3 Images', Pointer('Error - ' + Name), 0)
  else FILLine := nil;
end;

procedure TAoWLenLine.Draw(SurfDesc: GFXE.TSurfaceDesc);
begin
  try
    if (FValid = True) and (FVisible = True) then
    begin
      FILLine.DrawILLv(0, Rect(FAOWWindow.FWinLeft + FWinLeft,
        FAOWWindow.FWinTop + FWinTop, FWinWidth, FWinHeight), SurfDesc);
      if Assigned(FOnDraw) then FOnDraw(Self, SurfDesc);
    end;
  except
    MessageBox(0, 'Exception during Draw', Pointer('Error - ' + Name), 0);
  end;
end;

procedure TAoWLenLine.CheckMouseDown(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin
  inherited CheckMouseDown(Button, Shift, X, Y);
  FHandled := False;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
    if Assigned(FOnMouseDown) then FOnMouseDown(Self, Button, Shift, X, Y);
end;

procedure TAoWLenLine.CheckMouseUp(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin
  FHandled := False;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
    if Assigned(FOnMouseUp) then FOnMouseUp(Self, Button, Shift, X, Y);
end;

procedure TAoWLenLine.CheckMouseMove(Shift: Classes.TShiftState; X, Y: Integer);
begin
  FHandled := False;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
    if Assigned(FOnMouseMove) then FOnMouseMove(Self, Shift, X, Y);
end;

procedure TAoWLenLine.CheckKeyPress(var Key: Char);
begin
  FHandled := False;
end;

procedure Register;
begin
  RegisterComponents('AOW Tools', [TAoWLenLine]);
end;


initialization
finalization

end.
