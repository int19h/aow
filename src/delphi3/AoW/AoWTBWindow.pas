unit AoWTBWindow;

{ Draft declarations of AoWTBWindow, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AOWMenuBar, AoWButton, AoWCheckBox, AoWEdit, AoWFrame, AoWImage, AoWLabel, AoWPanel, AoWWindow, TurnButton;

type
  TTBWindow = class;


  { TTBWindow (size $144, VMT 00456CAC): $134/$138 indicator frame/step, $13C/$13E world/combat clock delays, $140 chat flash countdown. }
  TTBWindow = class(TDataModule)
  public
    published
    TaskWindow: TAOWWindow; { +0044 }
    TBNextButton: TAOWButton; { +0048 }
    StartMenuBar: TAOWMenuBar; { +004C }
    TBMessEdit: TAOWEdit; { +0050 }
    WGILbl: TAOWLabel; { +0054 }
    WGTLbl: TAOWLabel; { +0058 }
    TurnButton: TAOWTurnButton; { +005C }
    WMButton: TAOWButton; { +0060 }
    OVButton: TAOWButton; { +0064 }
    ConButton: TAOWButton; { +0068 }
    StructButton: TAOWButton; { +006C }
    OV2Btn: TAOWButton; { +0070 }
    InfoBtn: TAOWButton; { +0074 }
    ChatBtn: TAOWButton; { +0078 }
    TaskPanel: TAOWPanel; { +007C }
    WGIPnl: TAOWPanel; { +0080 }
    TBbk: TAoWFrame; { +0084 }
    TimerImg: TAOWImage; { +0088 }
    TimeIcn: TAOWImage; { +008C }
    TimeLbl: TAOWLabel; { +0090 }
    PInd: TAoWFrame; { +0094 }
    CurP: TAOWImage; { +0098 }
    TBWorld: TAOWPanel; { +009C }
    TCNextBtn: TAOWButton; { +00A0 }
    TCStartBar: TAOWMenuBar; { +00A4 }
    TCMsg: TAOWEdit; { +00A8 }
    TCTurnButton: TAOWTurnButton; { +00AC }
    TCScannerBtn: TAOWButton; { +00B0 }
    TCUnitBtn: TAOWButton; { +00B4 }
    AoWFrame1: TAoWFrame; { +00B8 }
    TCTimerImg: TAOWImage; { +00BC }
    TCTimeImg: TAOWImage; { +00C0 }
    TCTimeLbl: TAOWLabel; { +00C4 }
    TCPInd: TAoWFrame; { +00C8 }
    TCCurP: TAOWImage; { +00CC }
    TBCombat: TAOWPanel; { +00D0 }
    TCPnl: TAOWPanel; { +00D4 }
    TCChatBtn: TAOWButton; { +00D8 }
    WGoldPnl: TAOWPanel; { +00DC }
    WGSign: TAOWLabel; { +00E0 }
    WMILbl: TAOWLabel; { +00E4 }
    WMTLbl: TAOWLabel; { +00E8 }
    WMIPnl: TAOWPanel; { +00EC }
    WManaPnl: TAOWPanel; { +00F0 }
    WMTSign: TAOWLabel; { +00F4 }
    TGILbl: TAOWLabel; { +00F8 }
    TGTLbl: TAOWLabel; { +00FC }
    TGIcn: TAOWImage; { +0100 }
    TGIPnl: TAOWPanel; { +0104 }
    TGoldPnl: TAOWPanel; { +0108 }
    TGSign: TAOWLabel; { +010C }
    TMILbl: TAOWLabel; { +0110 }
    TMTLbl: TAOWLabel; { +0114 }
    TWMIcn: TAOWImage; { +0118 }
    TMIPnl: TAOWPanel; { +011C }
    TManaPnl: TAOWPanel; { +0120 }
    TMTSign: TAOWLabel; { +0124 }
    RelationsBtn: TAOWButton; { +0128 }
    AutoBtn: TAOWCheckBox; { +012C }
    Translator: TIvTranslator; { +0130 }
    public
    FIndicatorFrame: Integer; { $134 }
    FIndicatorStep: Integer; { $138 }
    FWorldClockDelay: Smallint; { $13C }
    FCombatClockDelay: Smallint; { $13E }
    FChatFlash: Smallint; { $140 }
    F_TBWindow_142: array[0..1] of Byte;
    procedure TurnButtonAnimDone;  { draft }
    procedure WMButtonClick;  { draft }
    procedure OVButtonClick(A1: Integer);  { draft }
    procedure ConButtonClick;  { draft }
    procedure StructButtonClick;  { draft }
    procedure TBNextButtonClick;  { draft }
    procedure UnitBtnClick;  { draft }
    procedure InfoBtnClick;  { draft }
    procedure ProdBtnClick;  { draft }
    procedure COBtnClick;  { draft }
    procedure ChatBtnClick;  { draft }
    procedure TurnButtonChange;  { draft }
    procedure PIndDraw(Sender: TObject; Surface: TSurfaceDesc);
    procedure CurPUpdate;  { draft }
    procedure TCTurnButtonChange;  { draft }
    procedure TCTurnButtonAnimDone;  { draft }
    procedure TCPIndDraw(Sender: TObject; Surface: TSurfaceDesc);
    procedure TCCurPUpdate;  { draft }
    procedure TCScannerBtnClick;  { draft }
    procedure TCNextBtnClick;  { draft }
    procedure TBWorldUpdate;  { draft }
    procedure TBCombatUpdate;  { draft }
    procedure OV2BtnClick;  { draft }
    procedure TCUnitBtnClick;  { draft }
    procedure StartMenuBarChange;  { draft }
    procedure RelationsBtnClick;  { draft }
    procedure ChatBtnUpdate(Sender: TAOWButton);
    procedure AutoBtn2Click;  { draft }
  end;


implementation

uses AoWE, AoWTC, AoWWinMan, E3Globals;

procedure TTBWindow.TurnButtonAnimDone;
begin
  TurnButton.Checked := False;
  if AoWCombatMap <> nil then AoWCombatMap.FEndTurnPending := True;
end;

procedure TTBWindow.WMButtonClick;
begin
  General.PlayButtonSound(0);
  SWindow.ScannerWindow.Visible := not SWindow.ScannerWindow.Visible;
end;

procedure TTBWindow.OVButtonClick(A1: Integer);
begin
  if A1 <> 0 then General.PlayButtonSound(0);
  RealmWin.Dlg.Visible := not RealmWin.Dlg.Visible;
  if RealmWin.Dlg.Visible then RealmWin.UpdateOverview;
end;

procedure TTBWindow.ConButtonClick;
begin
  General.PlayButtonSound(0);
  ControlWin.ControlWindow.Visible := not ControlWin.ControlWindow.Visible;
end;

procedure TTBWindow.StructButtonClick;
begin
  General.PlayButtonSound(0);
  IWindow.InfoWin.Visible := not IWindow.InfoWin.Visible;
end;

procedure TTBWindow.TBNextButtonClick;
begin
  General.PlayButtonSound(0);
  AoWHSMap.SelectNextArmy;
end;

procedure TTBWindow.UnitBtnClick;
begin
  General.PlayButtonSound(0);
  UnitWindow.UnitWin.Visible := True;
end;

procedure TTBWindow.InfoBtnClick;
begin end;

procedure TTBWindow.ProdBtnClick;
begin
  General.PlayButtonSound(0);
end;

procedure TTBWindow.COBtnClick;
begin
  General.PlayButtonSound(0);
end;

procedure TTBWindow.ChatBtnClick;
begin
  General.PlayButtonSound(0);
  ChatWindow.ChatWin.Visible := not ChatWindow.ChatWin.Visible;
end;

procedure TTBWindow.TurnButtonChange;
begin
  if not AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FSingleProcessCycle then
    TurnButton.Checked := AoWHSMap.EndTurn
  else TurnButton.Checked := not AoWHSMap.CancelEndTurn;
end;

procedure TTBWindow.PIndDraw(Sender: TObject; Surface: TSurfaceDesc);
var
  I, Position, Race: Integer;
begin
  Position := 0;
  if AoWHSMap <> nil then
    for I := 0 to AoWHSMap.FPlayers.GetCount - 1 do
      if AoWHSMap.FPlayers.GetPlayers(I).FStatus = psPlaying then
      begin
        Race := AoWHSMap.FPlayers.GetPlayers(I).FPlayerRace;
        if Race = -1 then Race := 12;
        IntGfxMod.TBWin[Race + 32].ShowClipped(PInd.WinLeft + 3 + Position * 5, PInd.WinTop + 2, Surface);
        if AoWHSMap.FPlayMode = pmTurn then
        begin
          if I = AoWHSMap.FCurrentPlayer then
          begin
            CurP.WinLeft := PInd.WinLeft + 2 + Position * 5;
            CurP.WinTop := PInd.WinTop + 11;
          end;
        end
        else
          if AoWHSMap.FPlayers.GetPlayers(I).FSingleProcessCycle then
            IntGfxMod.TBWin[50].ShowClipped(PInd.WinLeft + 2 + Position * 5, PInd.WinTop + 11, Surface);
        Inc(Position);
      end;
end;

procedure TTBWindow.CurPUpdate;
begin
  Inc(FIndicatorFrame, FIndicatorStep);
  if FIndicatorFrame > 4 then FIndicatorStep := -1;
  if FIndicatorFrame < 1 then FIndicatorStep := 1;
  CurP.CurrentImage := FIndicatorFrame + 45;
  PInd.FDrawn := False;
end;

procedure TTBWindow.TCTurnButtonChange;
begin
  if TCTurnButton.Checked then TCTurnButton.Checked := AoWCombatMap.EndTurn(False)
  else AoWCombatMap.CancelEndTurn;
end;

procedure TTBWindow.TCTurnButtonAnimDone;
begin
  General.Manager.OverlayPriority := 0;
  TCTurnButton.Checked := False;
  AoWCombatMap.FEndTurnPending := True;
end;

procedure TTBWindow.TCPIndDraw(Sender: TObject; Surface: TSurfaceDesc);
var
  I, Position, Race: Integer;
begin
  Position := 0;
  for I := 0 to AoWCombatMap.FCombat.FCombatData.FTurnOrder.Count - 1 do
  begin
    Race := AoWHSMap.FPlayers.GetPlayers(AoWCombatMap.FPlayers.GetPlayers(
      AoWCombatMap.FCombat.FCombatData.FTurnOrder[I]).FPlayer).FPlayerRace;
    if Race = -1 then Race := 12;
    IntGfxMod.TBWin[Race + 32].ShowClipped(TCPInd.WinLeft + 3 + Position * 5, TCPInd.WinTop + 2, Surface);
    if AoWCombatMap.FCombat.FCombatData.FTurnOrder[I] = AoWCombatMap.FCurrentCombatPlayer then
    begin
      TCCurP.WinLeft := TCPInd.WinLeft + 2 + Position * 5;
      TCCurP.WinTop := TCPInd.WinTop + 11;
    end;
    Inc(Position);
  end;
end;

procedure TTBWindow.TCCurPUpdate;
begin
  Inc(FIndicatorFrame, FIndicatorStep);
  if FIndicatorFrame > 4 then FIndicatorStep := -1;
  if FIndicatorFrame < 1 then FIndicatorStep := 1;
  TCCurP.CurrentImage := FIndicatorFrame + 45;
  TCPInd.FDrawn := False;
end;

procedure TTBWindow.TCScannerBtnClick;
begin
  General.PlayButtonSound(0);
  TCScanner.TCScannerWin.Visible := not TCScanner.TCScannerWin.Visible;
end;

procedure TTBWindow.TCNextBtnClick;
begin
  General.PlayButtonSound(0);
  AoWCombatMap.SelectNextUnit(True);
end;

procedure TTBWindow.TBWorldUpdate;
var
  Hour, Minute, Second, Millisecond: Word;
begin
  if TBWorld.Visible and (AoWHSMap <> nil) then
  begin
    Dec(FWorldClockDelay);
    if FWorldClockDelay < 0 then
      if AoWHSMap.FTurnTime = 0 then
      begin
        FWorldClockDelay := 900;
        DecodeTime(Time, Hour, Minute, Second, Millisecond);
        if Hour > 12 then Dec(Hour, 12);
        if Hour = 0 then Hour := 12;
        TimeLbl.Text := IntToStr(Hour) + ':';
        if Minute < 10 then TimeLbl.Text := TimeLbl.Text + '0';
        TimeLbl.Text := TimeLbl.Text + IntToStr(Minute);
      end
      else
      begin
        FWorldClockDelay := 10;
        Minute := AoWHSMap.GetTurnTimeLeft div 60000;
        Second := (AoWHSMap.GetTurnTimeLeft mod 60000) div 1000;
        if (Minute = 0) and (Second <> 0) and (Second < 11) then TimeLbl.TextColor := $FF
        else TimeLbl.TextColor := 0;
        TimeLbl.Text := IntToStr(Minute) + ':';
        if Second < 10 then TimeLbl.Text := TimeLbl.Text + '0';
        TimeLbl.Text := TimeLbl.Text + IntToStr(Second);
      end;
  end;
end;

procedure TTBWindow.TBCombatUpdate;
var
  Hour, Minute, Second, Millisecond: Word;
begin
  if TBCombat.Visible and (AoWCombatMap <> nil) then
  begin
    Dec(FCombatClockDelay);
    if FCombatClockDelay < 0 then
    begin
      FCombatClockDelay := 900;
      DecodeTime(Time, Hour, Minute, Second, Millisecond);
      if Hour > 12 then Dec(Hour, 12);
      if Hour = 0 then Hour := 12;
      TCTimeLbl.Text := IntToStr(Hour) + ':';
      if Minute < 10 then TCTimeLbl.Text := TCTimeLbl.Text + '0';
      TCTimeLbl.Text := TCTimeLbl.Text + IntToStr(Minute);
    end;
  end;
end;

procedure TTBWindow.OV2BtnClick;
begin end;

procedure TTBWindow.TCUnitBtnClick;
begin
  General.PlayButtonSound(0);
  TCUnit.TCUnitWin.Visible := not TCUnit.TCUnitWin.Visible;
end;

procedure TTBWindow.StartMenuBarChange;
begin
  General.PlayButtonSound(3);
end;

procedure TTBWindow.RelationsBtnClick;
begin end;

procedure TTBWindow.ChatBtnUpdate(Sender: TAOWButton);
var
  Button: TAOWButton;
begin
  if FChatFlash < 1 then Exit;
  Button := Sender;
  case FChatFlash of
    1, 31, 61, 91, 121: begin Button.FDrawn := False; Button.ILIndexUp := 14; end;
    16, 46, 76, 106, 136: begin Button.FDrawn := False; Button.ILIndexUp := 20; end;
  end;
  Dec(FChatFlash);
end;

procedure TTBWindow.AutoBtn2Click;
begin
  if AoWCombatMap.FSeatedCombatPlayer > -1 then
    AoWCombatMap.FPlayers.GetPlayers(AoWCombatMap.FSeatedCombatPlayer).SetAuto(AutoBtn.Checked);
end;


end.
