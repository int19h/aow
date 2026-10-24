unit AoWPartyJoin;

{ Partly recovered AoWPartyJoin handlers, from AoW.exe.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  Any remaining stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EventLog, AoWComp, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWMemo, AoWPanel, AoWWindow;

type
  TPartyJoinDlg = class;


  { TPartyJoinDlg: done callback $A4, join event $AC, details flag $B0, selection mask, unit list $B4, face unit $B8.
    (instance size 188, VMT 00437734) }
  TPartyJoinDlg = class(TDataModule)
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
    TitleIcon: TAOWImage; { +006C }
    Title: TAOWLabel; { +0070 }
    BCeltL: TAoWFrame; { +0074 }
    RightBtn: TAOWButton; { +0078 }
    LeftBtn: TAOWButton; { +007C }
    Dlg: TAOWWindow; { +0080 }
    UnitLine1: TAoWFrame; { +0084 }
    UnitLine2: TAoWFrame; { +0088 }
    JoinMemo: TAOWMemo; { +008C }
    Header: TAOWLabel; { +0090 }
    FaceFrame: TAOWImage; { +0094 }
    DetailsLbl: TAOWLabel; { +0098 }
    Close: TAOWButton; { +009C }
    Translator: TIvTranslator; { +00A0 }
    public
    FDone: TExecuteDoneEvent; { $A4 }
    FJoinEvent: TJoinEventLog; { $AC }
    FDetailsOpen: Boolean; { $B0 }
    FSelection: Byte; FReserved: array[0..1] of Byte; { $B1 }
    FUnits: TUnitUserList; { $B4 }
    FFaceUnit: TAbstractUnit; { $B8 }
    function ValidateJoin: Boolean;
    procedure FinishDialog;
    procedure DrawUnit(Index: Integer; const R: TRect; var Surface: TSurfaceDesc);
    published procedure PartyJoinDlgCreate; public  { draft }
    published procedure PartyJoinDlgDestroy; public  { draft }
    published procedure LeftBtnClick; public  { draft }
    published procedure MiddleBtnClick; public  { draft }
    published procedure RightBtnClick; public  { draft }
    published procedure CloseClick; public  { draft }
    published procedure FaceFramePreDraw(Sender: TAoWComponent; Surface: TSurfaceDesc); public  { draft }
    published procedure U1PreDraw(Sender: TAoWComponent; Surface: TSurfaceDesc); public  { draft }
    published procedure U1MouseDown(Sender: TAoWComponent; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); public  { draft }
    published procedure DlgHide; public  { draft }
    published procedure DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); public  { draft }
  end;


implementation

uses AoWWinMan, aowIntGfxMod, E3Globals;

function TPartyJoinDlg.ValidateJoin: Boolean;
begin
  Result := FJoinEvent.Validate;
  if not Result then Dlg.Visible := False;
end;

procedure TPartyJoinDlg.FinishDialog; { Tried with/local receiver; typed Self with; event identity increases allocation weight; named Self local after event locals; Self pointer identity changes register weighting; opaque event local with typed callback and release views; no exact match. }
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

procedure TPartyJoinDlg.DrawUnit(Index: Integer; const R: TRect; var Surface: TSurfaceDesc);
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

procedure TPartyJoinDlg.PartyJoinDlgCreate;
begin
  FUnits := TUnitUserList.Create(nil);
end;

procedure TPartyJoinDlg.PartyJoinDlgDestroy;
begin
  FUnits.Free;
end;

procedure TPartyJoinDlg.LeftBtnClick;
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

procedure TPartyJoinDlg.MiddleBtnClick;
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

procedure TPartyJoinDlg.RightBtnClick;
begin
  if ValidateJoin then
  begin
    General.PlayButtonSound(0);
    Dlg.Visible := False;
  end;
end;

procedure TPartyJoinDlg.CloseClick;
begin
  if ValidateJoin then
  begin
    General.PlayButtonSound(0);
    Dlg.Visible := False;
  end;
end;

procedure TPartyJoinDlg.FaceFramePreDraw(Sender: TAoWComponent; Surface: TSurfaceDesc);
var
  R: TRect;
begin
  if ValidateJoin then
  begin
    R.Left := FaceFrame.WinLeft + Dlg.WinLeft;
    R.Right := FaceFrame.WinWidth + R.Left;
    R.Top := FaceFrame.WinTop + Dlg.WinTop;
    R.Bottom := FaceFrame.WinHeight + R.Top;
    if FFaceUnit <> nil then
      if FFaceUnit.GetFace <> nil then FFaceUnit.GetFace.ShowStretched(R, Surface);
  end;
end;

procedure TPartyJoinDlg.U1PreDraw(Sender: TAoWComponent; Surface: TSurfaceDesc);
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
    DrawUnit(Sender.Tag, R, Surface);
  end;
end;

procedure TPartyJoinDlg.U1MouseDown(Sender: TAoWComponent; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); { Tried with/local receiver; Sender Pointer identity; opaque Sender plus Self pointer identity; no exact match. }
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

procedure TPartyJoinDlg.DlgHide;
begin
  FinishDialog;
end;

procedure TPartyJoinDlg.DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 27 then Dlg.Visible := False;
end;


end.
