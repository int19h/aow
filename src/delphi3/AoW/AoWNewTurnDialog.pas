unit AoWNewTurnDialog;

{ Draft declarations of AoWNewTurnDialog, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWFrame, AoWImage, AoWLabel, AoWWindow;

type
  TNewTurnDlg = class;


  { TNewTurnDlg (instance size 132, VMT 004391B0) }
  TNewTurnDlg = class(TDataModule)
  public
    published
    NewTDlg: TAOWWindow; { +0044 }
    TCeltB: TAoWFrame; { +0048 }
    ClickMsg: TAOWLabel; { +004C }
    LShield: TAOWImage; { +0050 }
    PlayerName: TAOWLabel; { +0054 }
    TurnMsg: TAOWLabel; { +0058 }
    PlayerRace: TAOWLabel; { +005C }
    Turn: TAOWLabel; { +0060 }
    RShield: TAOWImage; { +0064 }
    BlueFr: TAoWFrame; { +0068 }
    TCeltLineL: TAOWImage; { +006C }
    TCeltLineR: TAOWImage; { +0070 }
    FaceFrame: TAOWImage; { +0074 }
    public
    F_NewTurnDlg_78: array[0..7] of Byte;
    F_NewTurnDlg_80: Integer;
    procedure NewTDlgMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure NewTDlgKeyPress(A1: Integer; A2: Integer);  { draft }
    procedure FaceFramePreDraw(A1: Integer; A2: Integer);  { draft }
    procedure NewTDlgHide;  { draft }
  end;


implementation

procedure TNewTurnDlg.NewTDlgMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TNewTurnDlg.NewTDlgKeyPress(A1: Integer; A2: Integer);
begin end;

procedure TNewTurnDlg.FaceFramePreDraw(A1: Integer; A2: Integer);
begin end;

procedure TNewTurnDlg.NewTDlgHide;
begin end;


end.
