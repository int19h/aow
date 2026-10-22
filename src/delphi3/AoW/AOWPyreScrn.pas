unit AOWPyreScrn;

{ Draft declarations of AOWPyreScrn, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWImage, AoWPanel, aowUserDrawBox, AoWE, EventLog;

type
  TPyreScreen = class;


  { TPyreScreen (instance size $6C, VMT 004290B0): $64 game-over event, $68 animation frame. }
  TPyreScreen = class(TDataModule)
  public
    published
    DeadPnl: TAOWPanel; { +0044 }
    PyreTop: TAOWImage; { +0048 }
    LeaderFaceFr: TAOWImage; { +004C }
    PyreAnimation: TaowUserDrawBox; { +0050 }
    public
    FAnimation: TObject; FSavedSongStatus: TSongStatus; FDone: TExecuteDoneEvent; { $54, $58, $5C; 004293AC }
    { conflict: FFire: TSample; FSongStatus: TSongStatus; }
    FGameOverEvent: TGameOverEventLog; { $64 }
    FAnimationFrame: Integer; { $68 }
    procedure ClearFire;
    procedure FinishScreen;
    procedure ShowGameOver(Event: TGameOverEventLog; Done: TExecuteDoneEvent);
    published procedure DeadPnlUpdate; public  { draft }
    published procedure DeadPnlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); public
    published procedure LeaderFaceFrPreDraw(Sender: TObject; SD: TSurfaceDesc); public
    published procedure PyreAnimationUpdate; public  { draft }
    published procedure PyreAnimationDraw(Sender: TObject; SD: TSurfaceDesc); public
    published procedure DeadPnlKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); public
  end;


var
  PyreScreen: TPyreScreen;

implementation

uses AoWResultsWin, E3Globals, AoWWinMan, E1Globals, AoWExeForms, AoWVideoDlg;

procedure TPyreScreen.DeadPnlUpdate;
begin end;

procedure TPyreScreen.DeadPnlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin FinishScreen; end;

procedure TPyreScreen.LeaderFaceFrPreDraw(Sender: TObject; SD: TSurfaceDesc);
var
  R: TRect;
begin
  if AoWHSMap <> nil then
  begin
    R.Left := DeadPnl.WinLeft + LeaderFaceFr.WinLeft + $2D;
    R.Right := R.Left + $67;
    R.Top := DeadPnl.WinTop + LeaderFaceFr.WinTop + $23;
    R.Bottom := R.Top + $80;
    AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FLeader.ShowFace(R, SD);
  end;
end;


procedure TPyreScreen.PyreAnimationUpdate;
begin
  PyreAnimation.FDrawn := False; DeadPnl.FDrawn := False;
  Inc(FAnimationFrame);
  if FAnimationFrame > 450 then FinishScreen;
  if FAnimationFrame > $FFFFFF then FAnimationFrame := 0;
end;

procedure TPyreScreen.PyreAnimationDraw(Sender: TObject; SD: TSurfaceDesc);
var
  X, Y, Frame: Integer;
  Text: string;
begin
  X := PyreAnimation.WinWidth div 2;
  Y := PyreAnimation.WinHeight + 20 - FAnimationFrame div 2;
  if Y < 400 then Y := 400;
  Inc(Y, DeadPnl.WinTop);
  Inc(X, DeadPnl.WinLeft);
  case AoWHSMap.FPlayers.GetPlayers(FGameOverEvent.FPlayer).FGameOverStatus of
    goLost:
    begin
      Frame := (FAnimationFrame div 3) mod 9;
      if AoWEngine.FDemo then Frame := 0;
      IntGfxMod.PyreFrames[Frame].Show(DeadPnl.WinLeft + PyreAnimation.WinLeft,
        DeadPnl.WinTop + PyreAnimation.WinTop, SD);
      Text := AoWHSMap.FPlayers.GetPlayers(FGameOverEvent.FPlayer).GetNameEx + ', ' +
        TranslateRStr(YourReignHasEndedRStr);
      FontModule.AoW15BlackBrown.SetTextCentered(X, Y, Text, SD);
    end;
    goWon:
    begin
      IntGfxMod.VictoryFrames[0].Show(DeadPnl.WinLeft + PyreAnimation.WinLeft,
        DeadPnl.WinTop, SD);
      Text := AoWHSMap.FPlayers.GetPlayers(FGameOverEvent.FPlayer).GetNameEx + ', ' +
        TranslateRStr(YouWhereVictoriousRStr);
      FontModule.AoW15WhiteGrey.SetTextCentered(X, Y, Text, SD);
    end;
  end;
end;


procedure TPyreScreen.DeadPnlKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin case Key of VK_RETURN, VK_ESCAPE: FinishScreen; end; end;


procedure TPyreScreen.ClearFire;
begin
  if FAnimation <> nil then begin FAnimation.Free; FAnimation := nil; end;
end;

procedure TPyreScreen.FinishScreen;
begin
  ClearFire;
  IntGfxMod.PyreFrames.ReleaseDiscardableImageData;
  AOWPyreScrn.PyreScreen.DeadPnl.Visible := False;
  AoWResultsWin.ShowResults(ResultsWin);
end;

procedure TPyreScreen.ShowGameOver(Event: TGameOverEventLog; Done: TExecuteDoneEvent);
begin
  FAnimationFrame := 0;
  FGameOverEvent := Event; FGameOverEvent.AddRef; FDone := Done;
  FSavedSongStatus := BackupSongStatus;
  FadeMusicVolume(0, 1);
  General.Manager.OverlayPriority := 249;
  case AoWHSMap.FPlayers.GetPlayers(Event.FPlayer).FGameOverStatus of
    goLost:
      begin
        FAnimation := PlaySampleEx('Sfx\Attack\Fireloop.wav', 64, True, 0, spCenter, nil);
        AoWHSMap.FTutorialControl.ShowMessage(68, True, True);
      end;
    goWon: AoWHSMap.FTutorialControl.ShowMessage(67, True, True);
  end;
  IntGfxMod.PyreFrames.LoadDiscardableImageData;
  TitleWindow.TitlePnl.Visible := False;
  AOWPyreScrn.PyreScreen.DeadPnl.Visible := True;
  AoWExeForms.VideoDialog.SetSceneSize(640, 480);
  SetVideoMode(AoWExeForms.VideoDialog, scmTitle);
  AoWExeForms.VideoDialog.ApplyMode;
  TitleWindow.TitleWin.Visible := True;
  SetCurrentDir(ExtractFileDir(Application.ExeName));
end;

end.
