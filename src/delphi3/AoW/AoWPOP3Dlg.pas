unit AoWPOP3Dlg;

{ Draft declarations of AoWPOP3Dlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWEdit, AoWFrame, AoWImage, AoWLabel, AoWListBox, AoWPanel, AoWVScroll, AoWWindow;

type
  TPOP3Dlg = class;


  { TPOP3Dlg (instance size 168, VMT 00429ECC) }
  TPOP3Dlg = class(TDataModule)
  public
    published
    Dlg: TAOWWindow; { +0044 }
    TitleLbl: TAOWLabel; { +0048 }
    BCeltL: TAoWFrame; { +004C }
    TCeltL: TAoWFrame; { +0050 }
    TCeltLineL: TAOWImage; { +0054 }
    AOWImage1: TAOWImage; { +0058 }
    AOWImage2: TAOWImage; { +005C }
    SearchingEmailGameLbl: TAOWLabel; { +0060 }
    EmailGameFoundLbl: TAOWLabel; { +0064 }
    FoundEmailGames: TAOWListBox; { +0068 }
    ExitPnl: TAOWPanel; { +006C }
    Exit2Btn: TAOWButton; { +0070 }
    StartExitPnl: TAOWPanel; { +0074 }
    StartBtn: TAOWButton; { +0078 }
    ExitBtn: TAOWButton; { +007C }
    LocalEmailAddressEdit: TAOWEdit; { +0080 }
    AttachmentDirectoryLbl: TAOWLabel; { +0084 }
    TitleIcon: TAOWImage; { +0088 }
    EditPnl: TAOWPanel; { +008C }
    ModePnl: TAOWPanel; { +0090 }
    EmailGamesSB: TAOWVScrollBar; { +0094 }
    Close: TAOWButton; { +0098 }
    Translator: TIvTranslator; { +009C }
    public
    F_POP3Dlg_A0: array[0..3] of Byte;
    F_POP3Dlg_A4: Integer;
    procedure CancelBtnClick;  { draft }
    procedure DlgUpdate;  { draft }
    procedure ExitBtnClick;  { draft }
    procedure FoundEmailGamesChange;  { draft }
    procedure StartBtnClick;  { draft }
    procedure DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;


implementation

procedure TPOP3Dlg.CancelBtnClick;
begin end;

procedure TPOP3Dlg.DlgUpdate;
begin end;

procedure TPOP3Dlg.ExitBtnClick;
begin end;

procedure TPOP3Dlg.FoundEmailGamesChange;
begin end;

procedure TPOP3Dlg.StartBtnClick;
begin end;

procedure TPOP3Dlg.DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;


end.
