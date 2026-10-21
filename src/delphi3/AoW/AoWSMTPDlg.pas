unit AoWSMTPDlg;

{ Draft declarations of AoWSMTPDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AOWGauge, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWMemo, AoWPanel, AoWWindow, AoWE, EventLog, E3IMSTypes;

type
  { Declaration-only field type from ims.dpl (instance size 588). }
  TmsMessage = class(TComponent)
  public
    FHeader: TmsMessageHeader; { $24 } FSubject: ShortString; { $28 } FIncludeHeader, FEncode: Boolean; { $128/$129; 0044DBD5 } FReserved12A: array[0..9] of Byte; FAttachments: TmsAttList; { $134 } FReserved138: array[0..259] of Byte; FRecipients: TmsAddressList; { $23C } FReserved240: array[0..11] of Byte; procedure SetBody(Value: TStrings);
  end;

  { Declaration-only field type from ims.dpl (instance size 636). }
  TmsSMTP = class(TComponent)
  public
    FHost: string; { $24 }
    FReserved28: array[0..583] of Byte;
    FMessage: TmsMessage; { $270 }
    FReserved274: array[0..7] of Byte; procedure SetWinsockLoaded(Value: Boolean); property WinsockLoaded: Boolean write SetWinsockLoaded; { 0044DBB9 }
    procedure Send;
  end;

  { TIMSSendThread (instance size 44, VMT 0044D5D8) }
  TIMSSendThread = class(TThread)
  public
    FSuccess: Boolean; { $28 }
    F_IMSSendThread_29: array[0..2] of Byte;
    procedure Execute; override;
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
    FThread: TIMSSendThread; { $9C }
    FDone: TExecuteDoneEvent; { $A0 }
    FEvent: TSMTPEventLog; { $A8 }
    FProgress: Integer; { $AC }
    FFinished: Boolean; { $B0 }
    F_SMTPDlg_B1: array[0..2] of Byte;
    procedure FinishDialog;
    procedure ResetProgress;
    procedure StartSending;
    procedure IMSThreadTerminatedEvent(Sender: TObject);
    procedure DlgHide;  { draft }
    procedure ExitBtnClick;  { draft }
    procedure IMSSMTPProgress(Sender: TObject; Progress, Total: Integer);
    procedure ProgressBarUpdate;  { draft }
    procedure IMSSMTPError(Sender: TObject; var Error: string);
    procedure DlgUpdate;  { draft }
    procedure RetryBtnClick;  { draft }
    procedure SettingsBtnClick;  { draft }
  end;


var
  SMTPDlg: TSMTPDlg;

implementation

uses E3Globals;

procedure TmsSMTP.Send; external 'ims.dpl' name 'mssmtp.TmsSMTP.Send@23EDC2EF'; procedure TmsSMTP.SetWinsockLoaded(Value: Boolean); external 'ims.dpl' name 'agsocket.TagSocket.SetWinsockLoaded@23EDC2EF'; procedure TmsMessage.SetBody(Value: TStrings); external 'ims.dpl' name 'msmsg.TmsCustomMessage.SetBody@23EDC2EF';


procedure TIMSSendThread.Execute;
begin
  try
    SMTPDlg.IMSSMTP.Send;
    FSuccess := True;
  except
    FSuccess := False;
  end;
end;

procedure TSMTPDlg.FinishDialog;
var
  Done: TExecuteDoneEvent;
  Event: TSMTPEventLog;
begin
  Dlg.Visible := False;
  if FThread <> nil then
  begin
    FThread.Destroy;
    FThread := nil;
  end;
  Done := FDone;
  Event := FEvent;
  FDone := nil;
  FEvent := nil;
  if Assigned(Done) then Done(Event);
  if Event <> nil then Event.Release;
end;

procedure TSMTPDlg.ResetProgress;
begin
  FFinished := False;
  ProgressBar.Position := 0;
  SendingGameLbl.Text := TranslateRStr(SendingEmailGameRStr);
  FailedPnl.Visible := False;
  SendPnl.Visible := True;
  FProgress := 0;
  ExitBtn.Visible := False;
end;

procedure TSMTPDlg.StartSending;
begin
  ResetProgress;
  IMSSMTP.FHost := AoWEngine.FRegistry.GetSMTPServer;
  FThread := TIMSSendThread.Create(True);
  FThread.OnTerminate := IMSThreadTerminatedEvent;
  FThread.Resume;
end;

procedure TSMTPDlg.IMSThreadTerminatedEvent(Sender: TObject);
begin
  FEvent.FSuccess := FThread.FSuccess;
  FFinished := True;
  if FEvent.FSuccess then FProgress := 100;
end;

procedure TSMTPDlg.DlgHide;
begin
  FinishDialog;
end;

procedure TSMTPDlg.ExitBtnClick;
begin
  Dlg.Visible := False;
end;

procedure TSMTPDlg.IMSSMTPProgress(Sender: TObject; Progress, Total: Integer);
begin
  if Progress > FProgress then FProgress := Progress;
end;

procedure TSMTPDlg.ProgressBarUpdate;
begin
  if ProgressBar.Position <> FProgress then
  begin
    ProgressBar.Position := FProgress;
    ProgressBar.FDrawn := False;
  end;
end;

procedure TSMTPDlg.IMSSMTPError(Sender: TObject; var Error: string);
begin
  if FEvent <> nil then FEvent.FError := Error;
end;

procedure TSMTPDlg.DlgUpdate;
begin
  if FFinished then
    if FEvent.FSuccess then
    begin
      SendingGameLbl.Text := TranslateRStr(GameSuccessfullySentRStr);
      ExitBtn.Visible := True;
    end
    else
      with FailedPnl do
        if not Visible then
        begin
          Visible := True;
          SendPnl.Visible := False;
        end;
end;

procedure TSMTPDlg.RetryBtnClick;
begin
  StartSending;
end;

procedure TSMTPDlg.SettingsBtnClick;
begin
  ShowEmailSettings(EmailSettingsDlg);
end;

end.
