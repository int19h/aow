unit AoWPWindows;

{ Strategic and tactical popup menus, recovered from AoW.exe. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AOWMenu, StartMenu;

type
  TPopupWindows = class;


  { TPopupWindows: size $78; $44..$74 published menu components. VMT 00427450. }
  TPopupWindows = class(TDataModule)
  public
    published
    StartMenu: TStartMenu; { +0044 }
    OverViewsMenu: TAOWMenu; { +0048 }
    SettingsMenu: TAOWMenu; { +004C }
    EndMenu: TAOWMenu; { +0050 }
    DiskMenu: TAOWMenu; { +0054 }
    TCStartMenu: TStartMenu; { +0058 }
    Translator: TIvTranslator; { +005C }
    HelpMenu: TAOWMenu; { +0060 }
    TCOVMenu: TAOWMenu; { +0064 }
    TCDiskMenu: TAOWMenu; { +0068 }
    TCHelpMenu: TAOWMenu; { +006C }
    TCSettingsMenu: TAOWMenu; { +0070 }
    TCEndMenu: TAOWMenu; { +0074 }
    public
    procedure SettingsMenuSelect(Sender: TAOWMenu);
    procedure EndMenuSelect(Sender: TAOWMenu);
    procedure DiskMenuSelect(Sender: TAOWMenu);
    procedure OverViewsMenuSelect(Sender: TAOWMenu);
    procedure TCEndMenuSelect(Sender: TAOWMenu);
    procedure HelpMenuSelect(Sender: TAOWMenu);
  end;


implementation

uses ShellAPI, AoWE, AoWUnit, AoWWinMan, AoWVideoDlg, AoWSoundDlg,
  AoWExeForms, E2Globals, E2GameFlow, E1Globals, E1GameFlow, E3Globals, aowHelpWin,
  AoWGamePlayDlg, AoWFileDialog, E3EventDialogs;

procedure ShowVideoSettings(Dialog: TVideoDialog);
begin
  Dialog.Dlg.Visible := True;
  Dialog.UpdateModes;
end;

procedure ShowSoundSettings(Dialog: TSoundDlg);
begin
  Dialog.AddBtn.Visible := False;
  Dialog.FindFiles;
  Dialog.SoundSetup;
  Dialog.Dlg.Visible := True;
end;

procedure TPopupWindows.SettingsMenuSelect(Sender: TAOWMenu);
begin
  case Sender.FSelectedItem of
    0: ShowVideoSettings(VideoDialog);
    1: ShowSoundSettings(SoundDlg);
    2: GamePlayDialog.GamePlayDlg.Visible := True;
    3: General.ResetLayout;
    4: E3Globals.ShowEmailSettings(E3Globals.EmailSettingsDlg);
    5: E2Globals.DialogWin.DebugWin.Visible := True;
  end;
end;

procedure TPopupWindows.EndMenuSelect(Sender: TAOWMenu);
begin
  case Sender.FSelectedItem of
    0: E2GameFlow.ConfirmDialog(E2Globals.DialogWin, TranslateRStr(E2Globals.ConfirmRStr),
         TranslateRStr(SurrenderYourEmpireRStr), 4);
    1: AoWHSMap.ExitGame(egmTerminate, nil);
    2: if AoWEngine.FDemo then E2Globals.TitleWindow.ShowExitSplash else MainForm.Close;
  end;
end;

procedure TPopupWindows.DiskMenuSelect(Sender: TAOWMenu);
begin
  case Sender.FSelectedItem of
    0: begin AoWFileDialog.FileDlgWindow.FMode := 0; AoWFileDialog.FileDlgWindow.FileDialog.Visible := True; end;
    1: begin AoWFileDialog.FileDlgWindow.FMode := 1; AoWFileDialog.FileDlgWindow.FileDialog.Visible := True; end;
  end;
end;

procedure TPopupWindows.OverViewsMenuSelect(Sender: TAOWMenu);
begin
  case Sender.FSelectedItem of
    0: E3EventDialogs.ShowInformationBook(E1Globals.WorldMap, nil, nil); { Original opens the information book. }
    1: if AoWEngine.FCampaign <> nil then E1Globals.WorldMap.ShowSpheres;
  end;
end;

procedure TPopupWindows.TCEndMenuSelect(Sender: TAOWMenu);
begin
  case Sender.FSelectedItem of
    0: E2GameFlow.ConfirmDialog(E2Globals.DialogWin, TranslateRStr(E2Globals.ConfirmRStr),
         TranslateRStr(E2Globals.QuitCombatRStr), 6);
  end;
end;

procedure TPopupWindows.HelpMenuSelect(Sender: TAOWMenu);
begin
  case Sender.FSelectedItem of
    0: ShowHelp(507);
    1: ShowHelp(500);
    2: begin
         SetVideoMode(VideoDialog, scmWindowed);
         ApplyVideoSettings(VideoDialog);
         ShellExecute(Application.Handle, 'open', 'http://www.ageofwonders.com', nil, nil, 5);
       end;
  end;
end;

end.
