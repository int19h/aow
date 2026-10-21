unit AOWTitleWindow;

{ Draft declarations of AOWTitleWindow, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AOWInterfaceImgLib, AoWPanel, AoWWindow;

type
  TTitleWindow = class;


  { TTitleWindow (instance size 92, VMT 00429864) }
  TTitleWindow = class(TDataModule)
  public
    published
    TitleWin: TAOWWindow; { +0044 }
    TitlePnl: TAOWPanel; { +0048 }
    SplashPnl: TAOWPanel; { +004C }
    DemoIL: TInterfaceIL; { +0050 }
    public
    F_TitleWindow_54: Integer;
    F_TitleWindow_58: array[0..3] of Byte;
    procedure TitleWinDrawSurface(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure TitlePnlDrawBack(A1: Integer; A2: Integer);  { draft }
    procedure SplashPnlUpdate;  { draft }
    procedure SplashPnlKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure SplashPnlMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
  end;


implementation

procedure TTitleWindow.TitleWinDrawSurface(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TTitleWindow.TitlePnlDrawBack(A1: Integer; A2: Integer);
begin end;

procedure TTitleWindow.SplashPnlUpdate;
begin end;

procedure TTitleWindow.SplashPnlKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TTitleWindow.SplashPnlMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;


end.
