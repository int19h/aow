unit AOWControlWin;

{ Draft declarations of AOWControlWin, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWComp, AOWGauge, AoWButton, AoWCheckBox, AoWFrame, AoWImage, AoWLabel, AoWPanel, AoWWindow;

type
  TControlWin = class;


  { TControlWin (instance size $17C, VMT 00404910).
    $44..174 published controls; $178 inverted army selection mask. }
  TControlWin = class(TDataModule)
  public
    published
    ControlWindow: TAOWWindow; { +0044 }
    CWTitle: TAOWLabel; { +0048 }
    CWMinIcon: TAOWButton; { +004C }
    Unit1Frame: TAoWFrame; { +0050 }
    Unit2Frame: TAoWFrame; { +0054 }
    Unit3Frame: TAoWFrame; { +0058 }
    Unit4Frame: TAoWFrame; { +005C }
    Unit5Frame: TAoWFrame; { +0060 }
    Unit6Frame: TAoWFrame; { +0064 }
    Unit7Frame: TAoWFrame; { +0068 }
    Unit8Frame: TAoWFrame; { +006C }
    CTitleIcon: TAOWImage; { +0070 }
    MovesLbl: TAOWLabel; { +0074 }
    PartyStatusLbl: TAOWLabel; { +0078 }
    Close: TAOWButton; { +007C }
    U1MIcon: TAOWImage; { +0080 }
    U2MIcon: TAOWImage; { +0084 }
    U3MIcon: TAOWImage; { +0088 }
    U4MIcon: TAOWImage; { +008C }
    U5MIcon: TAOWImage; { +0090 }
    U6MIcon: TAOWImage; { +0094 }
    U7MIcon: TAOWImage; { +0098 }
    U8MIcon: TAOWImage; { +009C }
    MoraleMask: TAOWImage; { +00A0 }
    MoveIcon: TAOWImage; { +00A4 }
    PartyT1Pnl: TAOWPanel; { +00A8 }
    PartyBPnl: TAOWPanel; { +00AC }
    PartyT2Pnl: TAOWPanel; { +00B0 }
    PartyT3Pnl: TAOWPanel; { +00B4 }
    PartyT4Pnl: TAOWPanel; { +00B8 }
    Unit1Gge: TAoWGauge; { +00BC }
    Unit2Gge: TAoWGauge; { +00C0 }
    Unit3Gge: TAoWGauge; { +00C4 }
    Unit4Gge: TAoWGauge; { +00C8 }
    Unit5Gge: TAoWGauge; { +00CC }
    Unit6Gge: TAoWGauge; { +00D0 }
    Unit7Gge: TAoWGauge; { +00D4 }
    Unit8Gge: TAoWGauge; { +00D8 }
    Unit1Chk: TAOWCheckBox; { +00DC }
    Unit2Chk: TAOWCheckBox; { +00E0 }
    Unit3Chk: TAOWCheckBox; { +00E4 }
    Unit5Chk: TAOWCheckBox; { +00E8 }
    Unit6Chk: TAOWCheckBox; { +00EC }
    Unit7Chk: TAOWCheckBox; { +00F0 }
    Unit4Chk: TAOWCheckBox; { +00F4 }
    Unit8Chk: TAOWCheckBox; { +00F8 }
    Emp1Fr: TAoWFrame; { +00FC }
    Emp2Fr: TAoWFrame; { +0100 }
    Emp3Fr: TAoWFrame; { +0104 }
    Emp4Fr: TAoWFrame; { +0108 }
    Emp5Fr: TAoWFrame; { +010C }
    Emp6Fr: TAoWFrame; { +0110 }
    Emp7Fr: TAoWFrame; { +0114 }
    Emp8Fr: TAoWFrame; { +0118 }
    Emp1Chk: TAoWFrame; { +011C }
    Emp2Chk: TAoWFrame; { +0120 }
    Emp3Chk: TAoWFrame; { +0124 }
    Emp4Chk: TAoWFrame; { +0128 }
    Emp5Chk: TAoWFrame; { +012C }
    Emp6Chk: TAoWFrame; { +0130 }
    Emp7Chk: TAoWFrame; { +0134 }
    Emp8Chk: TAoWFrame; { +0138 }
    PartyIPnl: TAOWPanel; { +013C }
    PartyILbl: TAOWLabel; { +0140 }
    Center: TAOWButton; { +0144 }
    Help: TAOWButton; { +0148 }
    PPrev: TAOWButton; { +014C }
    PMove: TAOWButton; { +0150 }
    PNext: TAOWButton; { +0154 }
    PControlPnl: TAOWPanel; { +0158 }
    PGuard: TAOWCheckBox; { +015C }
    AoWFrame2: TAoWFrame; { +0160 }
    PartyB2Pbl: TAOWPanel; { +0164 }
    AoWFrame1: TAoWFrame; { +0168 }
    Translator: TIvTranslator; { +016C }
    PartyActionLbl1: TAOWLabel; { +0170 }
    PartyActionLbl2: TAOWLabel; { +0174 }
    public
    FSelection: Byte; { $178 }
    F_ControlWin_179: array[0..2] of Byte;
    procedure DrawUnit(Index: Integer; const R: TRect; var SD: TSurfaceDesc); { 00405D98 }
    procedure CWMinIconClick;  { draft }
    procedure CloseClick(Sender: TObject);
    procedure ControlWindowResize;  { draft }
    procedure Unit1FrameMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Unit1ChkChange(Sender: TObject);
    procedure CheckStart;  { draft }
    procedure CheckEnd;  { draft }
    procedure Unit1ChkMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CenterClick;  { draft }
    procedure Unit1FramePreDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc);
    procedure HelpClick;  { draft }
    procedure PPrevClick;  { draft }
    procedure PNextClick;  { draft }
    procedure PMoveClick;  { draft }
    procedure PGuardChange;  { draft }
  end;


implementation

uses AoWWinMan, E3Globals, aowHelpWin;


procedure TControlWin.DrawUnit(Index: Integer; const R: TRect; var SD: TSurfaceDesc);
begin
  if General.FSelectedUnits[Index] <> -1 then
    if General.FUnitList.GetUnit(General.FSelectedUnits[Index]).GetPreviewImage <> nil then
    begin
      SD.ClipRect := R;
      { Original tests the unsorted index when checking the background library. }
      if Ord(General.FUnitList.GetUnit(Index).GetAlignment) < IntGfxMod.UnitBGs.Count then
        IntGfxMod.UnitBGs[Ord(General.FUnitList.GetUnit(General.FSelectedUnits[Index]).GetAlignment)].ShowClipped(
          R.Left + (R.Right - R.Left - IntGfxMod.UnitBGs[Ord(General.FUnitList.GetUnit(General.FSelectedUnits[Index]).GetAlignment)].Width) div 2,
          R.Top + (R.Bottom - R.Top - IntGfxMod.UnitBGs[Ord(General.FUnitList.GetUnit(General.FSelectedUnits[Index]).GetAlignment)].Height) div 2, SD);
      General.FUnitList.GetUnit(General.FSelectedUnits[Index]).ShowEx(
        R.Left + (R.Right - R.Left - General.FUnitList.GetUnit(General.FSelectedUnits[Index]).GetPreviewImage.Width) div 2,
        R.Top + (R.Bottom - R.Top - General.FUnitList.GetUnit(General.FSelectedUnits[Index]).GetPreviewImage.Height) div 2,
        SD, General.FUnitShowInfo);
    end;
end;

procedure TControlWin.CWMinIconClick;
begin
  General.PlayButtonSound(0);
  ControlWindow.Visible := False;
end;

procedure TControlWin.CloseClick(Sender: TObject);
begin
  if Sender <> nil then General.PlayButtonSound(0);
  ControlWindow.Visible := False; TBWindow.ConButton.Visible := False;
end;

procedure TControlWin.ControlWindowResize;
begin
  with ControlWindow do
    with Alignment do
    begin
      RightOffset := WinManager.WinWidth - WinLeft - WinWidth;
      TopOffset := WinTop;
    end;
end;

procedure TControlWin.Unit1FrameMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  U: TAbstractUnit;
begin
  if (General.FUnitList <> nil) and (General.FSelectedUnits[TComponent(Sender).Tag] > -1) then
  begin
    U := General.FUnitList.GetUnit(General.FSelectedUnits[TComponent(Sender).Tag]);
    if U <> nil then
    begin
      General.FSelectedUnit := General.FUnitList.GetUnit(General.FSelectedUnits[TComponent(Sender).Tag]);
      if Button = mbLeft then UnitWindow.ShowUnit;
    end;
  end;
end;

procedure TControlWin.Unit1ChkChange(Sender: TObject);
begin
  CheckStart; AoWHSMap.FSelectedArmy.SetSelection(FSelection); CheckEnd;
  if TAOWCheckBox(Sender).Checked then General.PlayButtonSound(1) else General.PlayButtonSound(2);
end;

procedure TControlWin.CheckStart;
begin
  FSelection := 0;
  if not Unit1Chk.Checked and (General.FSelectedUnits[0] <> -1) then
    FSelection := FSelection or (1 shl General.FSelectedUnits[0]);
  if not Unit2Chk.Checked and (General.FSelectedUnits[1] <> -1) then
    FSelection := FSelection or (1 shl General.FSelectedUnits[1]);
  if not Unit3Chk.Checked and (General.FSelectedUnits[2] <> -1) then
    FSelection := FSelection or (1 shl General.FSelectedUnits[2]);
  if not Unit4Chk.Checked and (General.FSelectedUnits[3] <> -1) then
    FSelection := FSelection or (1 shl General.FSelectedUnits[3]);
  if not Unit5Chk.Checked and (General.FSelectedUnits[4] <> -1) then
    FSelection := FSelection or (1 shl General.FSelectedUnits[4]);
  if not Unit6Chk.Checked and (General.FSelectedUnits[5] <> -1) then
    FSelection := FSelection or (1 shl General.FSelectedUnits[5]);
  if not Unit7Chk.Checked and (General.FSelectedUnits[6] <> -1) then
    FSelection := FSelection or (1 shl General.FSelectedUnits[6]);
  if not Unit8Chk.Checked and (General.FSelectedUnits[7] <> -1) then
    FSelection := FSelection or (1 shl General.FSelectedUnits[7]);
end;

procedure TControlWin.CheckEnd;
begin
  FSelection := AoWHSMap.FSelectedArmy.GetSelection;
  Unit1Chk.Checked := (General.FSelectedUnits[0] <> -1) and
    ((FSelection and (1 shl General.FSelectedUnits[0])) = 0);
  Unit2Chk.Checked := (General.FSelectedUnits[1] <> -1) and
    ((FSelection and (1 shl General.FSelectedUnits[1])) = 0);
  Unit3Chk.Checked := (General.FSelectedUnits[2] <> -1) and
    ((FSelection and (1 shl General.FSelectedUnits[2])) = 0);
  Unit4Chk.Checked := (General.FSelectedUnits[3] <> -1) and
    ((FSelection and (1 shl General.FSelectedUnits[3])) = 0);
  Unit5Chk.Checked := (General.FSelectedUnits[4] <> -1) and
    ((FSelection and (1 shl General.FSelectedUnits[4])) = 0);
  Unit6Chk.Checked := (General.FSelectedUnits[5] <> -1) and
    ((FSelection and (1 shl General.FSelectedUnits[5])) = 0);
  Unit7Chk.Checked := (General.FSelectedUnits[6] <> -1) and
    ((FSelection and (1 shl General.FSelectedUnits[6])) = 0);
  Unit8Chk.Checked := (General.FSelectedUnits[7] <> -1) and
    ((FSelection and (1 shl General.FSelectedUnits[7])) = 0);
  if Unit1Chk.Checked then Unit1Frame.ILIndexFrame := 26 else Unit1Frame.ILIndexFrame := 12;
  if Unit2Chk.Checked then Unit2Frame.ILIndexFrame := 26 else Unit2Frame.ILIndexFrame := 12;
  if Unit3Chk.Checked then Unit3Frame.ILIndexFrame := 26 else Unit3Frame.ILIndexFrame := 12;
  if Unit4Chk.Checked then Unit4Frame.ILIndexFrame := 26 else Unit4Frame.ILIndexFrame := 12;
  if Unit5Chk.Checked then Unit5Frame.ILIndexFrame := 26 else Unit5Frame.ILIndexFrame := 12;
  if Unit6Chk.Checked then Unit6Frame.ILIndexFrame := 26 else Unit6Frame.ILIndexFrame := 12;
  if Unit7Chk.Checked then Unit7Frame.ILIndexFrame := 26 else Unit7Frame.ILIndexFrame := 12;
  if Unit8Chk.Checked then Unit8Frame.ILIndexFrame := 26 else Unit8Frame.ILIndexFrame := 12;
  MoveIcon.CurrentImage := General.MTtoInt(TArmy(General.FUnitList).GetPartyMoves(AoWHSMap.FSelectedArmy.GetSelection));
  MovesLbl.Text := IntToStr(TArmy(General.FUnitList).MovePoints(AoWHSMap.FSelectedArmy.GetSelection));
  PartyStatusLbl.Text := TranslateRStr(TPartyStatusRStr[AoWHSMap.FSelectedArmy.GetArmyHS.FArmy.GetPartyStatus(AoWHSMap.FSelectedArmy.GetSelection)]);
end;

procedure TControlWin.Unit1ChkMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
  begin
    CheckStart; AoWHSMap.FSelectedArmy.SetSelection(not FSelection); CheckEnd;
  end;
end;

procedure TControlWin.CenterClick;
begin
  General.PlayButtonSound(0);
  with TArmy(General.FUnitList) do AoWHSMap.CenterViewTo(FX, FY, FL);
  with TArmy(General.FUnitList) do AoWHSMap.PlayCenterAnimation(FX, FY, FL);
end;

procedure TControlWin.Unit1FramePreDraw(Sender: TAoWComponent; SurfDesc: TSurfaceDesc);
var
  SaveRect: TRect;
begin
  if General.FUnitList <> nil then
  begin
    SaveRect := SurfDesc.ClipRect;
    DrawUnit(Sender.Tag, Rect(Sender.AOWOwner.WinLeft + Sender.WinLeft + 4,
      Sender.AOWOwner.WinTop + Sender.WinTop + 3,
      Sender.AOWOwner.WinLeft + Sender.WinLeft + Sender.WinWidth - 3,
      Sender.AOWOwner.WinTop + Sender.WinTop + Sender.WinHeight - 7), SurfDesc);
    SurfDesc.ClipRect := SaveRect;
  end;
end;

procedure TControlWin.HelpClick;
begin
  ShowHelp(503);
end;

procedure TControlWin.PPrevClick;
begin
  AoWHSMap.SelectPrevArmy;
end;

procedure TControlWin.PNextClick;
begin
  AoWHSMap.SelectNextArmy;
end;

procedure TControlWin.PMoveClick;
begin
  AoWHSMap.FSelectedArmy.ExecuteMove;
end;

procedure TControlWin.PGuardChange;
begin
  if PGuard.Checked then
  begin
    if TArmy(General.FUnitList).FUserMode * [aumGuard] = [] then
      TArmy(General.FUnitList).FUserMode := TArmy(General.FUnitList).FUserMode + [aumGuard];
  end
  else
    if TArmy(General.FUnitList).FUserMode * [aumGuard] <> [] then
      TArmy(General.FUnitList).FUserMode := TArmy(General.FUnitList).FUserMode - [aumGuard];
end;


end.
