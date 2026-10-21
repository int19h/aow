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
    F_PyreScreen_54: array[0..15] of Byte;
    FGameOverEvent: TGameOverEventLog; { $64 }
    FAnimationFrame: Integer; { $68 }
    procedure DeadPnlUpdate;  { draft }
    procedure DeadPnlMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure LeaderFaceFrPreDraw(Sender: TObject; SD: TSurfaceDesc);
    procedure PyreAnimationUpdate;  { draft }
    procedure PyreAnimationDraw(Sender: TObject; SD: TSurfaceDesc);
    procedure DeadPnlKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;


implementation

uses E3Globals;

procedure TPyreScreen.DeadPnlUpdate;
begin end;

procedure TPyreScreen.DeadPnlMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

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
begin end;

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


procedure TPyreScreen.DeadPnlKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;


end.
