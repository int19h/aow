unit AoWMsgReceiveDlg;

{ Draft declarations of AoWMsgReceiveDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWImage, AoWMemo, AoWVScroll, AoWWindow;

type
  TMsgReceiveDlg = class;


  { TMsgReceiveDlg (instance size 112, VMT 00438EC4) }
  TMsgReceiveDlg = class(TDataModule)
  public
    published
    MsgReceiveWin: TAOWWindow; { +0044 }
    MessageMemo: TAOWMemo; { +0048 }
    Close: TAOWButton; { +004C }
    MessageSB: TAOWVScrollBar; { +0050 }
    LShield: TAOWImage; { +0054 }
    RShield: TAOWImage; { +0058 }
    HeaderMemo: TAOWMemo; { +005C }
    Translator: TIvTranslator; { +0060 }
    public
    F_MsgReceiveDlg_64: array[0..11] of Byte;
    procedure CloseClick;  { draft }
    procedure MsgReceiveWinHide;  { draft }
  end;


implementation

procedure TMsgReceiveDlg.CloseClick;
begin end;

procedure TMsgReceiveDlg.MsgReceiveWinHide;
begin end;


end.
