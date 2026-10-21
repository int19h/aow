unit AoWMessageDlg;

{ Draft declarations of AoWMessageDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWMemo, AoWPanel, AoWVScroll, AoWWindow;

type
  TMessageDlg = class;


  { TMessageDlg (instance size 188, VMT 0040E4E8) }
  TMessageDlg = class(TDataModule)
  public
    published
    Dlg: TAOWWindow; { +0044 }
    TitleLbl: TAOWLabel; { +0048 }
    YesNoPnl: TAOWPanel; { +004C }
    YesBtn: TAOWButton; { +0050 }
    NoBtn: TAOWButton; { +0054 }
    BCeltL: TAoWFrame; { +0058 }
    TCeltL: TAoWFrame; { +005C }
    TCeltLineL: TAOWImage; { +0060 }
    AOWImage1: TAOWImage; { +0064 }
    AOWImage2: TAOWImage; { +0068 }
    OKBtn: TAOWButton; { +006C }
    OKPnl: TAOWPanel; { +0070 }
    OKCancelPnl: TAOWPanel; { +0074 }
    OKBtn2: TAOWButton; { +0078 }
    CancelBtn: TAOWButton; { +007C }
    MessageMemo: TAOWMemo; { +0080 }
    MessageMemoSB: TAOWVScrollBar; { +0084 }
    YesNoCancelPnl: TAOWPanel; { +0088 }
    YesBtn2: TAOWButton; { +008C }
    NoBtn2: TAOWButton; { +0090 }
    CancelBtn2: TAOWButton; { +0094 }
    MemoPnl: TAOWPanel; { +0098 }
    HeaderMemoPnl: TAOWPanel; { +009C }
    HeaderMemo: TAOWMemo; { +00A0 }
    HeaderMemoSB: TAOWVScrollBar; { +00A4 }
    HeaderLbl: TAOWLabel; { +00A8 }
    Translator: TIvTranslator; { +00AC }
    public
    F_MessageDlg_B0: array[0..7] of Byte;
    F_MessageDlg_B8: Byte;
    F_MessageDlg_B9: array[0..2] of Byte;
    procedure DlgHide;  { draft }
    procedure YesBtnClick;  { draft }
    procedure NoBtnClick;  { draft }
    procedure OKBtnClick;  { draft }
    procedure OKBtn2Click;  { draft }
    procedure CancelBtnClick;  { draft }
  end;


implementation

procedure TMessageDlg.DlgHide;
begin end;

procedure TMessageDlg.YesBtnClick;
begin end;

procedure TMessageDlg.NoBtnClick;
begin end;

procedure TMessageDlg.OKBtnClick;
begin end;

procedure TMessageDlg.OKBtn2Click;
begin end;

procedure TMessageDlg.CancelBtnClick;
begin end;


end.
