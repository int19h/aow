unit AOWTitleWindow;

{ Title and timed splash screens, recovered from AoW.exe. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AOWInterfaceImgLib, AoWPanel, AoWWindow;

type
  TTitleWindow = class;


  { TTitleWindow: size $5C; $54 splash timer, $58 splash stage. VMT 00429864. }
  TTitleWindow = class(TDataModule)
  public
    published
    TitleWin: TAOWWindow; { +0044 }
    TitlePnl: TAOWPanel; { +0048 }
    SplashPnl: TAOWPanel; { +004C }
    DemoIL: TInterfaceIL; { +0050 }
    public
    FSplashTimer: Integer; { $54 }
    FSplashStage: Integer; { $58; 00429C2C }
    procedure HideSplash;
    procedure InitializeSplash;
    procedure ShowExitSplash;
    procedure NextSplash;
    procedure ShowSplash;
    procedure TitleWinDrawSurface(Sender: TObject; Surface: TSurface; X, Y: Integer);
    procedure TitlePnlDrawBack(Sender: TObject; SD: TSurfaceDesc);
    procedure SplashPnlUpdate;
    procedure SplashPnlKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SplashPnlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  end;


implementation

uses AoWE, AoWUnit, AoWExeForms, E2Globals, E2GameFlow, AoWVideoDlg, AoWComp, AoWSelFactionWin;

procedure TTitleWindow.TitleWinDrawSurface(Sender: TObject; Surface: TSurface; X, Y: Integer);
var
  SD: TSurfaceDesc;
begin
  if SelFactionWin.FactionPnl.Visible and (SelFactionWin.FFade >= 0) then
  begin
    Surface.Lock(SD);
    if SelFactionWin.FFadeDirection = 0 then
      IntGfxMod.FactionWin[SelFactionWin.FFadeImage].ShowBlended(
        SelFactionWin.FactionPnl.WinLeft, SelFactionWin.FactionPnl.WinTop, SD,
        AlphaBlendTable.LookupTables[100 - SelFactionWin.FFade])
    else
      IntGfxMod.FactionWin[SelFactionWin.FFadeImage].ShowBlended(
        SelFactionWin.FactionPnl.WinLeft, SelFactionWin.FactionPnl.WinTop, SD,
        AlphaBlendTable.LookupTables[SelFactionWin.FFade]);
    Surface.Unlock;
  end;
end;

procedure TTitleWindow.TitlePnlDrawBack(Sender: TObject; SD: TSurfaceDesc);
begin
  IntGfxMod.FactionWin[0].Show(SelFactionWin.FactionPnl.WinLeft, SelFactionWin.FactionPnl.WinTop, SD);
end;

procedure TTitleWindow.HideSplash;
begin
  DemoIL.ReleaseDiscardableImageData;
  SplashPnl.Visible := False;
  TitleWin.Visible := False;
end;

procedure TTitleWindow.InitializeSplash;
begin
  VideoDialog.SetSceneSize(640, 480);
  SetVideoMode(VideoDialog, scmTitle);
  VideoDialog.ApplyMode;
  TitleWin.Visible := True;
  TitlePnl.Visible := False;
  SplashPnl.ILTexture := DemoIL;
  SplashPnl.ILIndexTexture := 0;
  SplashPnl.Visible := True;
  FSplashTimer := 450;
  FSplashStage := 0;
end;

procedure TTitleWindow.ShowSplash;
begin
  InitializeSplash;
  SongPlayer.Songs.Clear;
  SongPlayer.Songs.Add('SONGS\TITLE.IT');
  SongPlayer.Play(0);
  SplashPnl.ILIndexTexture := 0;
  FSplashTimer := 450;
end;

procedure TTitleWindow.ShowExitSplash;
begin
  InitializeSplash;
  SplashPnl.ILIndexTexture := 2;
  FSplashStage := 10;
  FSplashTimer := 300;
end;

procedure TTitleWindow.NextSplash;
begin
  FSplashTimer := 300;
  case FSplashStage of
    0: begin SplashPnl.ILIndexTexture := 1; Inc(FSplashStage); end;
    1: begin HideSplash; ShowTitleScene(TitleScene, False); end;
    10: MainForm.Close;
  end;
end;

procedure TTitleWindow.SplashPnlUpdate;
begin
  Dec(FSplashTimer);
  if FSplashTimer = 0 then NextSplash;
end;

procedure TTitleWindow.SplashPnlKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 27 then
  begin
    HideSplash;
    ShowTitleScene(TitleScene, False);
  end
  else if not (ssAlt in Shift) then NextSplash;
end;

procedure TTitleWindow.SplashPnlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  NextSplash;
end;

end.
