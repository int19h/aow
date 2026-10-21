unit AOWPyreScrn;

{ Draft declarations of AOWPyreScrn, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWImage, AoWPanel, aowUserDrawBox;

type
  TPyreScreen = class;


  { TPyreScreen (instance size 108, VMT 004290B0) }
  TPyreScreen = class(TDataModule)
  public
    published
    DeadPnl: TAOWPanel; { +0044 }
    PyreTop: TAOWImage; { +0048 }
    LeaderFaceFr: TAOWImage; { +004C }
    PyreAnimation: TaowUserDrawBox; { +0050 }
    public
    F_PyreScreen_54: array[0..15] of Byte;
    F_PyreScreen_64: Integer;
    F_PyreScreen_68: Integer;
    procedure DeadPnlUpdate;  { draft }
    procedure DeadPnlMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure LeaderFaceFrPreDraw(A1: Integer; A2: Integer);  { draft }
    procedure PyreAnimationUpdate;  { draft }
    procedure PyreAnimationDraw(A1: Integer; A2: Integer);  { draft }
    procedure DeadPnlKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;


implementation

procedure TPyreScreen.DeadPnlUpdate;
begin end;

procedure TPyreScreen.DeadPnlMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TPyreScreen.LeaderFaceFrPreDraw(A1: Integer; A2: Integer);
begin end;

procedure TPyreScreen.PyreAnimationUpdate;
begin end;

procedure TPyreScreen.PyreAnimationDraw(A1: Integer; A2: Integer);
begin end;

procedure TPyreScreen.DeadPnlKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;


end.
