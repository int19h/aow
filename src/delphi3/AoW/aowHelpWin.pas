unit aowHelpWin;

{ Draft declarations of aowHelpWin, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWImage, AoWLabel, AoWMemo, AoWVScroll, AoWWindow;

type
  THelpWindow = class;


  { THelpWindow (instance size 136, VMT 004043F0) }
  THelpWindow = class(TDataModule)
  public
    published
    HelpWin: TAOWWindow; { +0044 }
    Title: TAOWLabel; { +0048 }
    CloseBtn: TAOWButton; { +004C }
    TitleIcon: TAOWImage; { +0050 }
    BBarEnd: TAOWImage; { +0054 }
    BBarBegin: TAOWImage; { +0058 }
    BCloseBut: TAOWButton; { +005C }
    CeltLineR: TAOWImage; { +0060 }
    BBar: TAOWImage; { +0064 }
    CeltLineL: TAOWImage; { +0068 }
    HelpSB: TAOWVScrollBar; { +006C }
    HeaderMemo: TAOWMemo; { +0070 }
    HelpMemo: TAOWMemo; { +0074 }
    Translator: TIvTranslator; { +0078 }
    public
    F_HelpWindow_7C: array[0..11] of Byte;
    procedure CloseBtnClick;  { draft }
    procedure HelpWinHide;  { draft }
    procedure HelpWinResize;  { draft }
  end;


procedure ShowHelp(HelpID: Integer); { draft; 0040471C }

implementation

procedure ShowHelp(HelpID: Integer);
begin end;

procedure THelpWindow.CloseBtnClick;
begin end;

procedure THelpWindow.HelpWinHide;
begin end;

procedure THelpWindow.HelpWinResize;
begin end;


end.
