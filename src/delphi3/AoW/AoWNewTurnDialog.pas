unit AoWNewTurnDialog;

{ Partly recovered AoWNewTurnDialog handlers, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Any remaining stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EventLog, AoWTC, AoWFrame, AoWImage, AoWLabel, AoWWindow;

type
  TNewTurnDlg = class;


  { TNewTurnDlg: done callback $78, new-turn event $80.
    (instance size 132, VMT 004391B0) }
  TNewTurnDlg = class(TDataModule)
  public
    published
    NewTDlg: TAOWWindow; { +0044 }
    TCeltB: TAoWFrame; { +0048 }
    ClickMsg: TAOWLabel; { +004C }
    LShield: TAOWImage; { +0050 }
    PlayerName: TAOWLabel; { +0054 }
    TurnMsg: TAOWLabel; { +0058 }
    PlayerRace: TAOWLabel; { +005C }
    Turn: TAOWLabel; { +0060 }
    RShield: TAOWImage; { +0064 }
    BlueFr: TAoWFrame; { +0068 }
    TCeltLineL: TAOWImage; { +006C }
    TCeltLineR: TAOWImage; { +0070 }
    FaceFrame: TAOWImage; { +0074 }
    public
    FDone: TExecuteDoneEvent; { $78 }
    FNewTurn: TNewTurnEventLog; { $80 }
    procedure FinishDialog;
    procedure ShowNewTurn(Event: TNewTurnEventLog; Unused: Integer; Done: TExecuteDoneEvent);
    procedure NewTDlgMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure NewTDlgKeyPress(Sender: TObject; var Key: Char);
    procedure FaceFramePreDraw(Sender: TObject; Surface: TSurfaceDesc);
    procedure NewTDlgHide;  { draft }
  end;


implementation

uses AoWWinMan, E3Globals;

procedure TNewTurnDlg.FinishDialog;
var
  Done: TExecuteDoneEvent;
  Event: TNewTurnEventLog;
begin
  General.Manager.OverlayPriority := 0;
  if FNewTurn = nil then
  begin
    AoWHSMap.SetSeatedPlayer(AoWHSMap.FCurrentPlayer);
    if AoWHSMap.FSeatedPlayer > -1 then PInfoW.UpdateEvents;
  end;
  Done := FDone;
  Event := FNewTurn;
  FDone := nil;
  FNewTurn := nil;
  if Assigned(Done) then Done(Event);
  if Event <> nil then Event.Release;
end;

procedure TNewTurnDlg.ShowNewTurn(Event: TNewTurnEventLog; Unused: Integer; Done: TExecuteDoneEvent);
var
  Race: Shortint;
  Day: Integer;
begin
  case Event.FMode of
    ntDialog:
    begin
      if FNewTurn <> nil then
      begin
        FNewTurn.Release;
        FNewTurn := nil;
      end;
      FDone := Done;
      FNewTurn := Event;
      FNewTurn.AddRef;
      TurnMsg.Text := Event.FText;
      PlayerName.Text := AoWHSMap.FPlayers.GetPlayers(Event.FTurnPlayer).GetName;
      if Event.FTurnPlayer <> 0 then
        PlayerRace.Text := TranslateRStr(RaceNamesPluralRStr[AoWHSMap.FPlayers.GetPlayers(Event.FTurnPlayer).FPlayerRace])
      else PlayerRace.Text := '';
      if AoWHSMap.FDay > 0 then Day := AoWHSMap.FDay
      else Day := 1;
      Turn.Text := TranslateRStr(DayRStr) + ' ' + IntToStr(Day);
      Race := AoWHSMap.FPlayers.GetPlayers(Event.FTurnPlayer).FPlayerRace;
      if Race = -1 then Race := 12;
      LShield.CurrentImage := Race + 26;
      RShield.CurrentImage := Race + 26;
      NewTDlg.FDrawn := False;
      NewTDlg.Visible := True;
      if nsCloseable in FNewTurn.FDialogStyle then ClickMsg.Text := TranslateRStr(ClickToBeginRStr)
      else ClickMsg.Text := TranslateRStr(HiddenmovementPleaseWaitRStr);
    end;
    ntClose: NewTDlg.Visible := False;
  end;
end;

procedure TNewTurnDlg.NewTDlgMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (AoWCombatMap = nil) and (nsCloseable in FNewTurn.FDialogStyle) then NewTDlg.Visible := False;
end;

procedure TNewTurnDlg.NewTDlgKeyPress(Sender: TObject; var Key: Char);
begin
  if (nsCloseable in FNewTurn.FDialogStyle) and ((Key = #32) or (Key = #13) or (Key = #27)) then NewTDlg.Visible := False;
end;

procedure TNewTurnDlg.FaceFramePreDraw(Sender: TObject; Surface: TSurfaceDesc);
var
  R: TRect;
begin
  if AoWCombatMap <> nil then
  begin
    if AoWHSMap.FPlayers.GetPlayers(AoWCombatMap.FSeatedPlayer).FLeader <> nil then
    begin
      with NewTDlg do R := Rect(WinLeft + 188, WinTop + 40, WinLeft + 188 + 103, WinTop + 40 + 128);
      AoWHSMap.FPlayers.GetPlayers(AoWCombatMap.FSeatedPlayer).FLeader.ShowFace(R, Surface);
    end;
  end
  else
    if AoWHSMap.FPlayers.GetPlayers(FNewTurn.FTurnPlayer).FLeader <> nil then
    begin
      with NewTDlg do R := Rect(WinLeft + 188, WinTop + 40, WinLeft + 188 + 103, WinTop + 40 + 128);
      AoWHSMap.FPlayers.GetPlayers(FNewTurn.FTurnPlayer).FLeader.ShowFace(R, Surface);
    end;
end;

procedure TNewTurnDlg.NewTDlgHide;
begin
  FinishDialog;
end;


end.
