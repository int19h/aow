unit AoWSendEmailGameDlg;

{ Partly recovered AoWSendEmailGameDlg handlers, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Any remaining stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EventLog, AoWButton, AoWCheckBox, AoWEdit, AoWFrame, AoWImage, AoWLabel, AoWPanel, AoWWindow, AoWSMTPDlg;

type
  TSendEmailGameDlg = class;


  { TSendEmailGameDlg: callback $A0, send event $A8.
    (instance size 172, VMT 0044D054) }
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
    FDone: TExecuteDoneEvent; { $A0 }
    FSendEvent: TSendEmailGameEventLog; { $A8 }
    procedure FinishDialog;
    procedure ShowSendDialog(Event: TSendEmailGameEventLog; Done: TExecuteDoneEvent);
    published procedure DlgHide; public  { draft }
    published procedure OKBtnClick; public  { draft }
    published procedure ExitBtnClick; public  { draft }
    published procedure EmailAddressEditChange; public  { draft }
    published procedure DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); public
  end;

  TIMSSendThread = AoWSMTPDlg.TIMSSendThread;



implementation


procedure TSendEmailGameDlg.FinishDialog;
var
  Done: TExecuteDoneEvent;
  Event: TEventLog;
begin
  Dlg.Visible := False;
  Done := FDone;
  Event := FSendEvent;
  FDone := nil;
  FSendEvent := nil;
  if Assigned(Done) then Done(Event);
  if Event <> nil then Event.Release;
end;

procedure TSendEmailGameDlg.ShowSendDialog(Event: TSendEmailGameEventLog; Done: TExecuteDoneEvent);
var
  S: string;
begin
  FDone := Done;
  FSendEvent := Event;
  Event.AddRef;
  with FSendEvent do
  begin
    EmailAddressEdit.Text := AoWHSMap.FPlayers.GetPlayers(FSendPlayer).FPBEMSettings.FEmailGame.FEmailAddress;
    S := AoWE.Format(TranslateRStr(NextPlayerXRStr), [AoWHSMap.FPlayers.GetPlayers(FSendPlayer).GetNameEx]);
    RecipientNameLbl.Text := S;
    if FMode = 2 then
    begin
      AutomatedChk.Checked := AoWEngine.FRegistry.GetSMTPServer <> '';
      ManualChk.Checked := AoWEngine.FRegistry.GetSMTPServer = '';
    end
    else
    begin
      AutomatedChk.Checked := FMode = 0;
      ManualChk.Checked := FMode = 1;
    end;
  end;
  Dlg.Visible := True;
end;

procedure TSendEmailGameDlg.DlgHide;
begin
  FinishDialog;
end;

procedure TSendEmailGameDlg.OKBtnClick;
begin
  if AutomatedChk.Checked then FSendEvent.FMode := 0;
  if ManualChk.Checked then FSendEvent.FMode := 1;
  Dlg.Visible := False;
end;

procedure TSendEmailGameDlg.ExitBtnClick;
begin
  FSendEvent.FMode := 2;
  Dlg.Visible := False;
end;

procedure TSendEmailGameDlg.EmailAddressEditChange;
begin
  AoWHSMap.FPlayers.GetPlayers(FSendEvent.FSendPlayer).FPBEMSettings.FEmailGame.FEmailAddress := EmailAddressEdit.Text;
end;

procedure TSendEmailGameDlg.DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 27 then Dlg.Visible := False;
end;



end.
