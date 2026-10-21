unit AoWPasswordDlg;

{ AoWPasswordDlg handlers recovered from AoW.exe.
  Class layouts and field offsets follow the original executable. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EventLog, AoWButton, AoWEdit, AoWFrame, AoWImage, AoWLabel, AoWPanel, AoWWindow;

type
  TPasswordDlg = class;


  { TPasswordDlg (instance size 124, VMT 0044DEA4) }
  TPasswordDlg = class(TDataModule)
  public
    published
    Dlg: TAOWWindow; { +0044 }
    TitleLbl: TAOWLabel; { +0048 }
    BCeltL: TAoWFrame; { +004C }
    TCeltL: TAoWFrame; { +0050 }
    TCeltLineL: TAOWImage; { +0054 }
    OKCancelPnl: TAOWPanel; { +0058 }
    OKBtn: TAOWButton; { +005C }
    CancelBtn: TAOWButton; { +0060 }
    PasswordLbl: TAOWLabel; { +0064 }
    PasswordEdit: TAOWEdit; { +0068 }
    Translator: TIvTranslator; { +006C }
    public
    FDone: TExecuteDoneEvent; { $70 }
    FPasswordEvent: TPasswordEventLog; { $78 }
    procedure Finish;
    procedure DlgHide;
    procedure OKBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  end;


implementation

procedure TPasswordDlg.Finish;
var
  Done: TExecuteDoneEvent;
  Event: TPasswordEventLog;
begin
  Done := FDone; Event := FPasswordEvent;
  FDone := nil; FPasswordEvent := nil;
  if Assigned(Done) then Done(Event);
  if Event <> nil then Event.Release;
end;

procedure TPasswordDlg.DlgHide;
begin Finish; end;

procedure TPasswordDlg.OKBtnClick(Sender: TObject);
begin
  FPasswordEvent.FPassword := PasswordEdit.Text;
  FPasswordEvent.FPressedButton := pebOk;
  Dlg.Visible := False;
end;

procedure TPasswordDlg.CancelBtnClick(Sender: TObject);
begin
  FPasswordEvent.FPassword := '';
  FPasswordEvent.FPressedButton := pebCancel;
  Dlg.Visible := False;
end;

procedure TPasswordDlg.DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then CancelBtnClick(nil);
end;

end.
