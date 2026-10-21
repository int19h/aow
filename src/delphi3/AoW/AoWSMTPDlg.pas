unit AoWSMTPDlg;

{ Draft declarations of AoWSMTPDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AOWGauge, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWMemo, AoWPanel, AoWWindow;

type
  { Declaration-only field type from ims.dpl (instance size 588). }
  TmsMessage = class(TComponent)
  private
    F_External: array[0..551] of Byte;
  end;

  { Declaration-only field type from ims.dpl (instance size 636). }
  TmsSMTP = class(TComponent)
  private
    F_External: array[0..599] of Byte;
  end;

  TSMTPDlg = class;


  { TSMTPDlg (instance size 180, VMT 0044D630) }
  TSMTPDlg = class(TDataModule)
  public
    published
    Dlg: TAOWWindow; { +0044 }
    BCeltL: TAoWFrame; { +0048 }
    TCeltL: TAoWFrame; { +004C }
    TCeltLineL: TAOWImage; { +0050 }
    AOWImage1: TAOWImage; { +0054 }
    AOWImage2: TAOWImage; { +0058 }
    ExitBtn: TAOWButton; { +005C }
    SendingGameLbl: TAOWLabel; { +0060 }
    ProgressBar: TAoWGauge; { +0064 }
    RecipientLbl: TAOWLabel; { +0068 }
    SendPnl: TAOWPanel; { +006C }
    FailedPnl: TAOWPanel; { +0070 }
    FailedMemo: TAOWMemo; { +0074 }
    SettingsBtn: TAOWButton; { +0078 }
    RetryBtn: TAOWButton; { +007C }
    ExitBtn2: TAOWButton; { +0080 }
    TitleLbl: TAOWLabel; { +0084 }
    Close: TAOWButton; { +0088 }
    TitleIcon: TAOWImage; { +008C }
    IMSMessage: TmsMessage; { +0090 }
    IMSSMTP: TmsSMTP; { +0094 }
    Translator: TIvTranslator; { +0098 }
    public
    F_SMTPDlg_9C: Integer;
    F_SMTPDlg_A0: array[0..7] of Byte;
    F_SMTPDlg_A8: Integer;
    F_SMTPDlg_AC: Integer;
    F_SMTPDlg_B0: Byte;
    F_SMTPDlg_B1: array[0..2] of Byte;
    procedure IMSThreadTerminatedEvent;  { draft }
    procedure DlgHide;  { draft }
    procedure ExitBtnClick;  { draft }
    procedure IMSSMTPProgress(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure ProgressBarUpdate;  { draft }
    procedure IMSSMTPError(A1: Integer; A2: Integer);  { draft }
    procedure DlgUpdate;  { draft }
    procedure RetryBtnClick;  { draft }
    procedure SettingsBtnClick;  { draft }
  end;


implementation

procedure TSMTPDlg.IMSThreadTerminatedEvent;
begin end;

procedure TSMTPDlg.DlgHide;
begin end;

procedure TSMTPDlg.ExitBtnClick;
begin end;

procedure TSMTPDlg.IMSSMTPProgress(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TSMTPDlg.ProgressBarUpdate;
begin end;

procedure TSMTPDlg.IMSSMTPError(A1: Integer; A2: Integer);
begin end;

procedure TSMTPDlg.DlgUpdate;
begin end;

procedure TSMTPDlg.RetryBtnClick;
begin end;

procedure TSMTPDlg.SettingsBtnClick;
begin end;


end.
