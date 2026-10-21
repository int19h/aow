unit AOWMWindow;

{ Draft declarations of AOWMWindow, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWWindow, AoWComp;

type
  TMWindow = class;


  { TMWindow: size $70; $5C saved map rectangle, $6D/$6F saved alignment. VMT 00450C38. }
  TMWindow = class(TDataModule)
  public
    published
    MapWindow: TAOWWindow; { +0044 }
    MapViewer: THSMapViewer; { +0048 }
    public
    FWorldRect: TRect; { $4C }
    FMapRect: TRect; { $5C }
    { conflict: FCombatRect: TRect; }
    FWorldAlignWidth: TAOWAlignWidth; { $6C }
    FMapAlignWidth: AoWComp.TAOWAlignWidth; { $6D }
    { conflict: FCombatAlignWidth: TAOWAlignWidth; }
    FWorldAlignHeight: TAOWAlignHeight; { $6E }
    FMapAlignHeight: AoWComp.TAOWAlignHeight; { $6F }
    { conflict: FCombatAlignHeight: TAOWAlignHeight; }
    procedure MWindowCreate;  { draft }
    procedure MapWindowMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure MapWindowMouseUp(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure MapWindowMouseMove(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure MapViewerSceneChanged;  { draft }
    procedure MapWindowResize;  { draft }
    procedure MapWindowExit(A1: Integer; A2: Integer);  { draft }
    procedure MapWindowUpdate;  { draft }
    procedure MapWindowPreDrawSurface(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure MapWindowKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;


implementation

procedure TMWindow.MWindowCreate;
begin end;

procedure TMWindow.MapWindowMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TMWindow.MapWindowMouseUp(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TMWindow.MapWindowMouseMove(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TMWindow.MapViewerSceneChanged;
begin end;

procedure TMWindow.MapWindowResize;
begin end;

procedure TMWindow.MapWindowExit(A1: Integer; A2: Integer);
begin end;

procedure TMWindow.MapWindowUpdate;
begin end;

procedure TMWindow.MapWindowPreDrawSurface(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TMWindow.MapWindowKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;


end.
