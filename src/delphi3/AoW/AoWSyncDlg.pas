unit AoWSyncDlg;

{ AoWSyncDlg handlers recovered from AoW.exe.
  Class layouts and field offsets follow the original executable. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWSetup, AoWFrame, AoWImage, AoWLabel, AoWPanel, AoWWindow;

type
  TSynchronizeDlg = class;


  { TSynchronizeDlg (instance size 128, VMT 00413334) }
  TSynchronizeDlg = class(TDataModule)
  public
    published
    Dlg: TAOWWindow; { +0044 }
    TCeltB: TAoWFrame; { +0048 }
    BottomMsg: TAOWLabel; { +004C }
    LShield: TAOWImage; { +0050 }
    PlayerName: TAOWLabel; { +0054 }
    InfoMsg: TAOWLabel; { +0058 }
    PlayerRace: TAOWLabel; { +005C }
    Turn: TAOWLabel; { +0060 }
    RShield: TAOWImage; { +0064 }
    BlueFr: TAoWFrame; { +0068 }
    TCeltLineL: TAOWImage; { +006C }
    TCeltLineR: TAOWImage; { +0070 }
    NewTPnl: TAOWPanel; { +0074 }
    FaceFrame: TAOWImage; { +0078 }
    Translator: TIvTranslator; { +007C }
    public
    function GetPlayerSetup: TPlayerSetupSettings;
    published procedure FaceFramePreDraw(Sender: TObject; Surface: TSurfaceDesc); public
    published procedure DlgShow; public
  end;


implementation

uses aowSetupEvents;

function TSynchronizeDlg.GetPlayerSetup: TPlayerSetupSettings;
var
  Index: Integer;
begin
  Index := SetupEvents.SetupControl.FSettings.IndexOfRemoteID(SetupEvents.SetupControl.FRemotePlayer.FRemoteID);
  if Index <> -1 then Result := SetupEvents.SetupControl.FSettings.GetSettings(Index)
  else Result := nil;
end;

procedure TSynchronizeDlg.FaceFramePreDraw(Sender: TObject; Surface: TSurfaceDesc);
var
  Settings: TPlayerSetupSettings;
  R: TRect;
begin
  Settings := GetPlayerSetup;
  if Settings <> nil then
  begin
    R := Rect(Dlg.WinLeft + 188, Dlg.WinTop + 40, Dlg.WinLeft + 291, Dlg.WinTop + 40 + 128);
    Settings.FLeader.ShowFace(R, Surface);
  end;
end;

procedure TSynchronizeDlg.DlgShow;
var
  Settings: TPlayerSetupSettings;
  I, Day: Integer;
begin
  Settings := GetPlayerSetup;
  if Settings <> nil then
  begin
    if not SetupEvents.SetupControl.FSettings.FCustomizeLeaders then
    begin
      I := SetupEvents.SetupControl.FSettings.FRemotePlayers.IndexOfRemoteID(SetupEvents.SetupControl.FRemotePlayer.FRemoteID);
      if I <> -1 then PlayerName.Text := SetupEvents.SetupControl.FSettings.FRemotePlayers.GetPlayers(I).FName
      else PlayerName.Text := Settings.FLeader.FHeroName;
    end
    else PlayerName.Text := Settings.FLeader.FHeroName;
    PlayerRace.Text := TranslateRStr(RaceNamesPluralRStr[Settings.FRace]);
    Day := AoWHSMap.FDay;
    if Day = 0 then Day := 1;
    Turn.Text := TranslateRStr(DayRStr) + ' ' + IntToStr(Day);
    LShield.CurrentImage := Settings.FRace + 26;
    RShield.CurrentImage := Settings.FRace + 26;
  end;
end;

end.
