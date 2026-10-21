unit AoWTargetSelection;

{ Draft declarations of AoWTargetSelection, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWArnoLine, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWMemo, AoWPanel, AoWWindow;

type
  TTargetSelectionDlg = class;


  { TTargetSelectionDlg (instance size 132, VMT 004445D8) }
  TTargetSelectionDlg = class(TDataModule)
  public
    published
    Dlg: TAOWWindow; { +0044 }
    CeltFrame: TAoWFrame; { +0048 }
    Close: TAOWButton; { +004C }
    Title: TAOWLabel; { +0050 }
    SIcon: TAOWImage; { +0054 }
    MainBtn: TAOWButton; { +0058 }
    DefaultMemo: TAOWMemo; { +005C }
    DefaultPnl: TAOWPanel; { +0060 }
    HeaderLbl: TAOWLabel; { +0064 }
    HeaderPnl: TAOWPanel; { +0068 }
    BorderImage: TAoWArnoLine; { +006C }
    SpellPnl: TAOWPanel; { +0070 }
    SpellMemo: TAOWMemo; { +0074 }
    TargetRangeLabel: TAOWLabel; { +0078 }
    TargetLbl: TAOWLabel; { +007C }
    Translator: TIvTranslator; { +0080 }
    public
    procedure CloseClick;  { draft }
    procedure MainBtnClick;  { draft }
  end;


implementation

procedure TTargetSelectionDlg.CloseClick;
begin end;

procedure TTargetSelectionDlg.MainBtnClick;
begin end;


end.
