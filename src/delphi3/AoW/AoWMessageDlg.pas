unit AoWMessageDlg;

{ Draft declarations of AoWMessageDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, EventLog, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWMemo, AoWPanel, AoWVScroll, AoWWindow;

type
  TMessageDlg = class;


  { TMessageDlg (size $BC, VMT 0040E4E8): $B0 completion event, $B8 retained message event. }
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
    FDone: TExecuteDoneEvent; { $B0 }
    FEvent: TMessageEventLog; { $B8 }
    procedure FinishDialog; { 0040E780 }
    procedure DlgHide;  { draft }
    procedure YesBtnClick;  { draft }
    procedure NoBtnClick;  { draft }
    procedure OKBtnClick;  { draft }
    procedure OKBtn2Click;  { draft }
    procedure CancelBtnClick;  { draft }
  end;


procedure ShowDemoMessage;

var MessageDlg: TMessageDlg;

implementation

uses AoWE, AoWExeForms;

procedure TMessageDlg.FinishDialog;
var
  Done: TExecuteDoneEvent;
  Log: TMessageEventLog;
begin
  Dlg.Visible := False;
  Done := FDone;
  Log := FEvent;
  FDone := nil;
  FEvent := nil;
  if Assigned(Done) then Done(Log);
  if Log <> nil then Log.Release;
end;


procedure TMessageDlg.DlgHide;
begin
  FinishDialog;
end;

procedure TMessageDlg.YesBtnClick;
begin
  if FEvent.Yes then Dlg.Visible := False;
end;

procedure TMessageDlg.NoBtnClick;
begin
  if FEvent.No then Dlg.Visible := False;
end;

procedure TMessageDlg.OKBtnClick;
begin
  if FEvent <> nil then
    if not FEvent.OK then Exit;
  Dlg.Visible := False;
end;

procedure TMessageDlg.OKBtn2Click;
begin
  if FEvent.OK then Dlg.Visible := False;
end;

procedure TMessageDlg.CancelBtnClick;
begin
  if FEvent.Cancel then Dlg.Visible := False;
end;


procedure ShowDemoMessage;
begin
  ResetMessageDialog(MessageDlg);
  MessageDlg.MessageMemo.Items.Add('');
  MessageDlg.MessageMemo.Items.Add(TranslateRStr(DemoVersionMessageRStr));
  MessageDlg.OKPnl.Visible := True;
  MessageDlg.Dlg.Visible := True;
end;

end.
