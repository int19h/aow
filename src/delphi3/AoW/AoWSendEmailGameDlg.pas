unit AoWSendEmailGameDlg;

{ Draft declarations of AoWSendEmailGameDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWCheckBox, AoWEdit, AoWFrame, AoWImage, AoWLabel, AoWPanel, AoWWindow;

type
  TSendEmailGameDlg = class;
  TIMSSendThread = class;


  { TSendEmailGameDlg (instance size 172, VMT 0044D054) }
  TSendEmailGameDlg = class(TDataModule)
  public
    published
    Dlg: TAOWWindow; { +0044 }
    TitleLbl: TAOWLabel; { +0048 }
    BCeltL: TAoWFrame; { +004C }
    TCeltL: TAoWFrame; { +0050 }
    TCeltLineL: TAOWImage; { +0054 }
    AOWImage1: TAOWImage; { +0058 }
    AOWImage2: TAOWImage; { +005C }
    OKCancelPnl: TAOWPanel; { +0060 }
    OKBtn: TAOWButton; { +0064 }
    ExitBtn: TAOWButton; { +0068 }
    EmailAddressEdit: TAOWEdit; { +006C }
    SeletModeInfoLbl: TAOWLabel; { +0070 }
    ManualChk: TAOWCheckBox; { +0074 }
    AutomatedChk: TAOWCheckBox; { +0078 }
    ManualLbl: TAOWLabel; { +007C }
    AutomatedLbl: TAOWLabel; { +0080 }
    RecipientNameLbl: TAOWLabel; { +0084 }
    TitleIcon: TAOWImage; { +0088 }
    ModePnl: TAOWPanel; { +008C }
    ModePnlin: TAOWPanel; { +0090 }
    EditPnl: TAOWPanel; { +0094 }
    Close: TAOWButton; { +0098 }
    Translator: TIvTranslator; { +009C }
    public
    F_SendEmailGameDlg_A0: array[0..7] of Byte;
    F_SendEmailGameDlg_A8: Integer;
    procedure DlgHide;  { draft }
    procedure OKBtnClick;  { draft }
    procedure ExitBtnClick;  { draft }
    procedure EmailAddressEditChange;  { draft }
    procedure DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;

  { TIMSSendThread (instance size 44, VMT 0044D5D8) }
  TIMSSendThread = class(TThread)
  public
    F_IMSSendThread_28: Byte;
    F_IMSSendThread_29: array[0..2] of Byte;
    procedure Execute; override;
  end;


implementation

procedure TSendEmailGameDlg.DlgHide;
begin end;

procedure TSendEmailGameDlg.OKBtnClick;
begin end;

procedure TSendEmailGameDlg.ExitBtnClick;
begin end;

procedure TSendEmailGameDlg.EmailAddressEditChange;
begin end;

procedure TSendEmailGameDlg.DlgKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TIMSSendThread.Execute;
begin end;


end.
