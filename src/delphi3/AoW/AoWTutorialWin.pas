unit AoWTutorialWin;

{ Draft declarations of AoWTutorialWin, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWMemo, AoWVScroll, AoWWindow;

type
  TTutorialWindow = class;


  { TTutorialWindow (instance size 104, VMT 0044E1C0) }
  TTutorialWindow = class(TDataModule)
  public
    published
    Dlg: TAOWWindow; { +0044 }
    MessageMemo: TAOWMemo; { +0048 }
    Close: TAOWButton; { +004C }
    HeaderMemo: TAOWMemo; { +0050 }
    AbVSB: TAOWVScrollBar; { +0054 }
    Translator: TIvTranslator; { +0058 }
    public
    F_TutorialWindow_5C: array[0..11] of Byte;
    procedure DlgHide;  { draft }
    procedure CloseClick;  { draft }
  end;


implementation

procedure TTutorialWindow.DlgHide;
begin end;

procedure TTutorialWindow.CloseClick;
begin end;


end.
