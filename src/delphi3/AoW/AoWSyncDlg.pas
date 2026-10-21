unit AoWSyncDlg;

{ Draft declarations of AoWSyncDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWFrame, AoWImage, AoWLabel, AoWPanel, AoWWindow;

type
  TSynchronizeDlg = class;


  { TSynchronizeDlg (instance size 128, VMT 00413334) }
  TSynchronizeDlg = class(TDataModule)
  public
    published
    Dlg: TAOWWindow; { +0044 }
    TCeltB: TAoWFrame; { +0048 }
    BottomMsg: TAOWLabel; { +004C }
    LShield: TAOWImage; { +0050 }
    PlayerName: TAOWLabel; { +0054 }
    InfoMsg: TAOWLabel; { +0058 }
    PlayerRace: TAOWLabel; { +005C }
    Turn: TAOWLabel; { +0060 }
    RShield: TAOWImage; { +0064 }
    BlueFr: TAoWFrame; { +0068 }
    TCeltLineL: TAOWImage; { +006C }
    TCeltLineR: TAOWImage; { +0070 }
    NewTPnl: TAOWPanel; { +0074 }
    FaceFrame: TAOWImage; { +0078 }
    Translator: TIvTranslator; { +007C }
    public
    procedure FaceFramePreDraw(A1: Integer; A2: Integer);  { draft }
    procedure DlgShow;  { draft }
  end;


implementation

procedure TSynchronizeDlg.FaceFramePreDraw(A1: Integer; A2: Integer);
begin end;

procedure TSynchronizeDlg.DlgShow;
begin end;


end.
