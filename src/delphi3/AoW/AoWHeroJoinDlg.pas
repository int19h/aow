unit AoWHeroJoinDlg;

{ Partly recovered AoWHeroJoinDlg handlers, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Any remaining stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EventLog, AoWComp, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWMemo, AoWPanel, AoWWindow;

type
  THeroJoinDlg = class;


  { THeroJoinDlg: done callback $94, join event $9C, details flag $A0, selection mask, unit list $A4, face unit $A8.
    (instance size 172, VMT 004382E8) }
  THeroJoinDlg = class(TDataModule)
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
    MiddleBtn: TAOWButton; { +0068 }
    BCeltL: TAoWFrame; { +006C }
    RightBtn: TAOWButton; { +0070 }
    LeftBtn: TAOWButton; { +0074 }
    Dlg: TAOWWindow; { +0078 }
    HeroName: TAOWLabel; { +007C }
    HeroLevel: TAOWLabel; { +0080 }
    FaceFrame: TAOWImage; { +0084 }
    DetailsLbl: TAOWLabel; { +0088 }
    JoinMemo: TAOWMemo; { +008C }
    Translator: TIvTranslator; { +0090 }
    public
    FDone: TExecuteDoneEvent; { $94 }
    FJoinEvent: TJoinEventLog; { $9C }
    FDetailsOpen: Boolean; { $A0 }
    FSelection: Byte; FReserved: array[0..1] of Byte; { $A1 }
    FUnits: TUnitUserList; { $A4 }
    FFaceUnit: TAbstractUnit; { $A8 }
    function ValidateJoin: Boolean;
    procedure FinishDialog;
    procedure DrawUnit(Index: Integer; const R: TRect; var Surface: TSurfaceDesc);
    published procedure HeroJoinDlgCreate; public  { draft }
    published procedure HeroJoinDlgDestroy; public  { draft }
    published procedure LeftBtnClick; public  { draft }
    published procedure MiddleBtnClick; public  { draft }
    published procedure RightBtnClick; public  { draft }
    published procedure FaceFramePreDraw(Sender: TAoWComponent; Surface: TSurfaceDesc); public  { draft }
    published procedure U1PreDraw(Sender: TObject; Surface: TSurfaceDesc); public  { draft }
    published procedure U1MouseDown(Sender: TAoWComponent; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); public  { draft }
    published procedure DlgHide; public  { draft }
    published procedure DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); public  { draft }
  end;


implementation

uses AoWWinMan, aowIntGfxMod, E3Globals;

function THeroJoinDlg.ValidateJoin: Boolean;
begin
  Result := FJoinEvent.Validate;
  if not Result then Dlg.Visible := False;
end;

procedure THeroJoinDlg.FinishDialog;
var
  Event: TEventLog;
  Done: TExecuteDoneEvent;
begin
  FUnits.Clear;
  if FDetailsOpen then
  begin
    FDetailsOpen := False;
    UnitWindow.UnitWin.Priority := ControlWin.ControlWindow.Priority;
    UnitWindow.UnitWin.Visible := False;
  end;
  Done := FDone;
  Event := FJoinEvent;
  FDone := nil;
  FJoinEvent := nil;
  if Assigned(Done) then Done(Event);
  if Event <> nil then Event.Release;
end;

procedure THeroJoinDlg.DrawUnit(Index: Integer; const R: TRect; var Surface: TSurfaceDesc);
var
  Alignment: AoWE.TAlignment;
  X, Y: Integer;
  OldClip: TRect;
  Info: TP2UnitShowInfo;
begin
  if Index < FUnits.GetCount then
  begin
    OldClip := Surface.ClipRect;
    Surface.ClipRect := R;
    X := (R.Right + R.Left) div 2;
    Y := (R.Top + R.Bottom) div 2;
    Alignment := FUnits.GetUnit(Index).GetAlignment;
    if Ord(Alignment) < IntGfxMod.UnitBGs.Count then
      with IntGfxMod.UnitBGs[Integer(Alignment)] do
        ShowClipped(X - Width div 2, Y - Height div 2, Surface);
    FillChar(Info, SizeOf(Info), 0);
    Info.Direction := 3;
    Info.Overlays := [uoHitPoints, uoRank];
    FUnits.GetUnit(Index).ShowEx(X - 33, Y - 35, Surface, Info);
    if (FSelection shr Index) and 1 = 0 then
      with IntGfxMod.UnitBGs[7] do
        ShowClipped(X - Width div 2, Y - Height div 2, Surface);
    Surface.ClipRect := OldClip;
  end;
end;

procedure THeroJoinDlg.HeroJoinDlgCreate;
begin
  FUnits := TUnitUserList.Create(nil);
end;

procedure THeroJoinDlg.HeroJoinDlgDestroy;
begin
  FUnits.Free;
end;

procedure THeroJoinDlg.LeftBtnClick;
var
  Reason: string;
begin
  if ValidateJoin then
  begin
    General.PlayButtonSound(0);
    if not FJoinEvent.Accept(Reason) then AoWHSMap.ShowWarning(Reason)
    else Dlg.Visible := False;
  end;
end;

procedure THeroJoinDlg.MiddleBtnClick;
var
  Reason: string;
begin
  if ValidateJoin then
  begin
    General.PlayButtonSound(0);
    if not FJoinEvent.Reject(Reason) then AoWHSMap.ShowWarning(Reason)
    else Dlg.Visible := False;
  end;
end;

procedure THeroJoinDlg.RightBtnClick;
begin
  if ValidateJoin then
  begin
    General.PlayButtonSound(0);
    Dlg.Visible := False;
  end;
end;

procedure THeroJoinDlg.FaceFramePreDraw(Sender: TAoWComponent; Surface: TSurfaceDesc);
var
  R: TRect;
begin
  if ValidateJoin then
  begin
    R.Left := FaceFrame.WinLeft + Dlg.WinLeft;
    R.Right := FaceFrame.WinWidth + R.Left;
    R.Top := FaceFrame.WinTop + Dlg.WinTop;
    R.Bottom := FaceFrame.WinHeight + R.Top;
    if FFaceUnit.GetFace <> nil then FFaceUnit.GetFace.ShowStretched(R, Surface);
  end;
end;

procedure THeroJoinDlg.U1PreDraw(Sender: TObject; Surface: TSurfaceDesc);
var
  R: TRect;
begin
  if ValidateJoin then
  begin
    with TAoWComponent(Sender) do
    begin
      R.Left := WinLeft + UnitPnl.WinLeft + 1;
      R.Right := WinWidth + R.Left;
      R.Top := WinTop + UnitPnl.WinTop;
      R.Bottom := WinHeight + R.Top;
    end;
    DrawUnit(TAoWComponent(Sender).Tag, R, Surface);
  end;
end;

procedure THeroJoinDlg.U1MouseDown(Sender: TAoWComponent; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if ValidateJoin then
    if Sender.Tag < FUnits.GetCount then
    begin
      General.FSelectedUnit := FUnits.GetUnit(Sender.Tag);
      if Button = mbLeft then
      begin
        FDetailsOpen := True;
        UnitWindow.ShowUnit;
        UnitWindow.UnitWin.Priority := Dlg.Priority + 1;
      end;
    end;
end;

procedure THeroJoinDlg.DlgHide;
begin
  FinishDialog;
end;

procedure THeroJoinDlg.DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 27 then Dlg.Visible := False;
end;


end.
