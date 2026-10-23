unit TCFCDlg;

{ Combat-mode selection, map preview and completion recovered from AoW.exe.
  Layouts and field offsets follow the original executable. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWComp, AoWButton, AoWCheckBox, AoWFrame, AoWImage, AoWLabel, AoWPanel, AoWWindow, aowUserDrawBox;

type
  TTCFCDialog = class;


  { TTCFCDialog: size $98; $8C combat request, $90 completion event. VMT 00439834. }
  TTCFCDialog = class(TDataModule)
  public
    published
    Dlg: TAOWWindow; { +0044 }
    DTitle: TAOWLabel; { +0048 }
    DMessage: TAOWLabel; { +004C }
    FightBtn: TAOWButton; { +0050 }
    CancelBtn: TAOWButton; { +0054 }
    BCeltL: TAoWFrame; { +0058 }
    TCeltL: TAoWFrame; { +005C }
    TCeltLineL: TAOWImage; { +0060 }
    AOWImage1: TAOWImage; { +0064 }
    AOWImage2: TAOWImage; { +0068 }
    Tactical: TAOWLabel; { +006C }
    Automatic: TAOWLabel; { +0070 }
    TCchk: TAOWCheckBox; { +0074 }
    FCchk: TAOWCheckBox; { +0078 }
    MapViewPnl: TAOWPanel; { +007C }
    MapView: TaowUserDrawBox; { +0080 }
    InfoSep: TAOWImage; { +0084 }
    Translator: TIvTranslator; { +0088 }
    public
    FRequest: TCombatTypeRequestEventLog; { $8C }
    FOnDone: TNotifyEvent; { $90 }
    procedure Finish;
    published procedure CancelBtnClick; public
    published procedure FightBtnClick; public
    published procedure FCchkChange(Sender: TObject); public
    published procedure TCchkChange(Sender: TObject); public
    published procedure MapViewDraw(Sender: TObject; SD: TSurfaceDesc); public
    published procedure MapViewUpdate; public
    published procedure DlgHide; public
    published procedure TCchkDoubleClick(Sender: TObject); public
    published procedure FCchkDoubleClick(Sender: TObject); public
  end;


implementation

uses AoWWinMan;

procedure TTCFCDialog.CancelBtnClick;
begin
  General.PlayButtonSound(0);
  FRequest.Select(TCombatType(0));
  Dlg.Visible := False;
end;

procedure TTCFCDialog.FightBtnClick;
begin
  General.PlayButtonSound(0);
  Dlg.Visible := False;
end;

procedure TTCFCDialog.FCchkChange(Sender: TObject);
begin
  with TAOWCheckBox(Sender) do
  begin
    if Checked then FRequest.Select(TCombatType(1));
    if Checked then General.PlayButtonSound(1) else General.PlayButtonSound(2);
  end;
end;

procedure TTCFCDialog.TCchkChange(Sender: TObject);
begin
  with TAOWCheckBox(Sender) do
  begin
    if Checked then FRequest.Select(TCombatType(2));
    if Checked then General.PlayButtonSound(1) else General.PlayButtonSound(2);
  end;
end;

procedure TTCFCDialog.MapViewDraw(Sender: TObject; SD: TSurfaceDesc);
var
  X, Y: Integer;
  ViewSD: TSurfaceDesc;
  R: TRect;
  W, H: Integer;
begin
  R := Rect(Dlg.WinLeft + TAoWComponent(Sender).WinLeft, Dlg.WinTop + TAoWComponent(Sender).WinTop,
    Dlg.WinLeft + TAoWComponent(Sender).WinLeft + TAoWComponent(Sender).WinWidth,
    Dlg.WinTop + TAoWComponent(Sender).WinTop + TAoWComponent(Sender).WinHeight);
  W := R.Right - R.Left;
  H := R.Bottom - R.Top;
  HXtoHP(FRequest.FX, FRequest.FY, X, Y);
  X := X + 16 - (W shr 1);
  Y := Y + 16 - (H shr 1);
  if X < 16 then X := 16;
  if Y < 16 then Y := 16;
  CreateSDfromSD(SD, R, ViewSD);
  AoWHSMap.SetViewPort(X, Y, FRequest.FL, R.Right - R.Left, R.Bottom - R.Top);
  AoWHSMap.UpdateStaticScene;
  AoWHSMap.UpdateDynamicScene;
  AoWHSMap.DrawStaticScene(ViewSD);
  AoWHSMap.DrawDynamicScene(ViewSD);
end;

procedure TTCFCDialog.MapViewUpdate;
begin MapView.FDrawn := MapView.FDrawn and Odd(AoWHSMap.Frame); end;

procedure TTCFCDialog.DlgHide;
begin Finish; end;

procedure TTCFCDialog.Finish;
var
  Done: TNotifyEvent;
  Request: TCombatTypeRequestEventLog;
begin
  General.Manager.OverlayPriority := 0;
  Done := FOnDone;
  Request := FRequest;
  FOnDone := nil;
  FRequest := nil;
  if Assigned(Done) then Done(Request);
  if Request <> nil then Request.Release;
end;

procedure TTCFCDialog.TCchkDoubleClick(Sender: TObject);
begin
  if TAOWCheckBox(Sender).Checked then FRequest.Select(TCombatType(2));
  Dlg.Visible := False;
end;

procedure TTCFCDialog.FCchkDoubleClick(Sender: TObject);
begin
  if TAOWCheckBox(Sender).Checked then FRequest.Select(TCombatType(1));
  Dlg.Visible := False;
end;

end.
