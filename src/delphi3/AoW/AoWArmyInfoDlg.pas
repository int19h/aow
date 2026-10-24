unit AoWArmyInfoDlg;

{ Draft declarations of AoWArmyInfoDlg, from AoW.exe.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWComp, City, WizardsTower, EventLog, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWMemo, AoWPanel, AoWWindow;

type
  TArmyInfoDlg = class;


  { TArmyInfoDlg (instance size $AC, VMT 004475A0).
    $9C unit-info window open; $A0 completion callback; $A8 army-info event. }
  TArmyInfoDlg = class(TDataModule)
  public
    published
    UnitPnl: TAOWPanel; { +0044 }
    U1: TAoWFrame; { +0048 }
    U2: TAoWFrame; { +004C }
    U4: TAoWFrame; { +0050 }
    U5: TAoWFrame; { +0054 }
    U3: TAoWFrame; { +0058 }
    U6: TAoWFrame; { +005C }
    U7: TAoWFrame; { +0060 }
    U8: TAoWFrame; { +0064 }
    CloseBtn: TAOWButton; { +0068 }
    TitleIcon: TAOWImage; { +006C }
    Close: TAOWButton; { +0070 }
    Title: TAOWLabel; { +0074 }
    BCeltL: TAoWFrame; { +0078 }
    Dlg: TAOWWindow; { +007C }
    UnitLine1: TAoWFrame; { +0080 }
    UnitLine2: TAoWFrame; { +0084 }
    Message: TAOWMemo; { +0088 }
    FaceFrame: TAOWImage; { +008C }
    DetailsLbl: TAOWLabel; { +0090 }
    HeaderLbl: TAOWLabel; { +0094 }
    Translator: TIvTranslator; { +0098 }
    public
    FUnitInfoShown: Boolean; { $9C }
    F_ArmyInfoDlg_9D: array[0..2] of Byte; FOnClose: TExecuteDoneEvent; { $A0 }
    FEvent: TArmyInfoEventLog; { $A8 }
    procedure DrawUnit(Index: Integer; const R: TRect; var SD: TSurfaceDesc);
    procedure ClearEvent;
    published procedure CloseBtnClick; public  { draft }
    published procedure CloseClick; public  { draft }
    published procedure U1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); public
    published procedure U1PreDraw(Sender: TAoWComponent; SD: TSurfaceDesc); public
    published procedure FaceFramePreDraw(Sender: TAoWComponent; SD: TSurfaceDesc); public
    published procedure DlgHide; public  { draft }
    published procedure DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); public
  end;


implementation

uses AoWWinMan, E3Globals;

procedure TArmyInfoDlg.DrawUnit(Index: Integer; const R: TRect; var SD: TSurfaceDesc);
var
  SaveRect: TRect;
  Info: TP2UnitShowInfo;
  Img: TLibraryImage;
  Alignment: TAlignment;
  X, Y: Integer;
begin
  if Index < FEvent.FArmyView.GetCount then
  begin
    SaveRect := SD.ClipRect; SD.ClipRect := R;
    X := (R.Right + R.Left) div 2; Y := (R.Top + R.Bottom) div 2;
    Alignment := FEvent.FArmyView.GetUnit(Index).GetAlignment;
    if Ord(Alignment) < IntGfxMod.UnitBGs.Count then
    begin
      Img := IntGfxMod.UnitBGs[Ord(Alignment)]; { D3 masks the enum index after the original full-byte guard. }
      Img.ShowClipped(X - Img.Width div 2, Y - Img.Height div 2, SD);
    end;
    FillChar(Info, SizeOf(Info), 0); Info.Direction := 3; Info.Overlays := [uoHitPoints, uoRank];
    FEvent.FArmyView.GetUnit(Index).ShowEx(X - 33, Y - 35, SD, Info);
    if ((FEvent.FSelection shr Index) and 1) = 0 then
    begin
      Img := IntGfxMod.UnitBGs[7];
      Img.ShowClipped(X - Img.Width div 2, Y - Img.Height div 2, SD);
    end;
    SD.ClipRect := SaveRect;
  end;
end;

procedure TArmyInfoDlg.ClearEvent; { Tried with/local receiver; typed Self with; event identity increases allocation weight; named Self local after event locals; Self pointer identity changes register weighting; opaque event local with typed callback and release views; no exact match. }
var
  Event: TArmyInfoEventLog;
  Notify: TExecuteDoneEvent;
begin
  if FUnitInfoShown then
  begin
    FUnitInfoShown := False;
    UnitWindow.UnitWin.Priority := ControlWin.ControlWindow.Priority;
    UnitWindow.UnitWin.Visible := False;
  end;
  Notify := FOnClose; Event := FEvent;
  FOnClose := nil; FEvent := nil;
  if Assigned(Notify) then Notify(Event);
  if Event <> nil then Event.Release;
end;

procedure TArmyInfoDlg.CloseBtnClick;
begin
  General.PlayButtonSound(0);
  Dlg.Visible := False;
end;

procedure TArmyInfoDlg.CloseClick;
begin
  General.PlayButtonSound(0);
  Dlg.Visible := False;
end;

procedure TArmyInfoDlg.U1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin Sender := TObject(Pointer(Sender));
  if TComponent(Sender).Tag < FEvent.FArmyView.GetCount then
  begin
    General.FSelectedUnit := FEvent.FArmyView.GetUnit(TComponent(Sender).Tag);
    if Button = mbLeft then
    begin
      FUnitInfoShown := True; UnitWindow.ShowUnit;
      UnitWindow.UnitWin.Priority := Dlg.Priority + 1;
    end;
  end;
end;

procedure TArmyInfoDlg.U1PreDraw(Sender: TAoWComponent; SD: TSurfaceDesc);
var
  R: TRect;
begin
  with TAOWImage(Sender) do
  begin
    R.Left := WinLeft + UnitPnl.WinLeft + 1; R.Right := WinWidth + R.Left;
    R.Top := WinTop + UnitPnl.WinTop; R.Bottom := WinHeight + R.Top;
    DrawUnit(Sender.Tag, R, SD);
  end;
end;

procedure TArmyInfoDlg.FaceFramePreDraw(Sender: TAoWComponent; SD: TSurfaceDesc);
var
  R: TRect;
  I: Integer;
begin Self := TArmyInfoDlg(Pointer(Self));
  with FaceFrame do
  begin
    R.Left := WinLeft + Dlg.WinLeft; R.Right := WinWidth + R.Left;
    R.Top := WinTop + Dlg.WinTop; R.Bottom := WinHeight + R.Top;
  end;
  I := 0;
  while ((FEvent.FSelection and (1 shl I)) = 0) and (I <> FEvent.FArmyView.GetCount) do Inc(I);
  if I < FEvent.FArmyView.GetCount then FEvent.FArmyView.GetUnit(I).ShowFace(R, SD);
end;

procedure TArmyInfoDlg.DlgHide;
begin
  ClearEvent;
end;

procedure TArmyInfoDlg.DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) or (Key = VK_SPACE) then Dlg.Visible := False;
end;


end.
