unit AoWMsgReceiveDlg;

{ Draft declarations of AoWMsgReceiveDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWImage, AoWMemo, AoWVScroll, AoWWindow, EventLog;

type
  TMsgReceiveDlg = class;


  { TMsgReceiveDlg (instance size $70, VMT 00438EC4): $64 done callback, $6C retained event. }
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
    FDone: TExecuteDoneEvent; { $64 } FEvent: TEventLog; { $6C }
    procedure FinishDialog;
    procedure CloseClick;
    procedure MsgReceiveWinHide;
  end;


implementation

uses AoWWinMan;

procedure TMsgReceiveDlg.CloseClick;
begin
  General.PlayButtonSound(0);
  MsgReceiveWin.Visible := False;
end;


procedure TMsgReceiveDlg.MsgReceiveWinHide;
begin
  FinishDialog;
end;



procedure TMsgReceiveDlg.FinishDialog;
var
  Done: TExecuteDoneEvent;
  Log: TEventLog;
begin
  Done := FDone;
  Log := FEvent;
  FDone := nil;
  FEvent := nil;
  if Assigned(Done) then Done(Log);
  if Log <> nil then Log.Release;
end;

end.
