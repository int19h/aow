unit AoWSWindow;

{ AoWSWindow handlers recovered from AoW.exe.
  Class layouts and field offsets follow the original executable. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWCheckBox, AoWFrame, AoWImage, AoWLabel, AoWTabPanel, AoWWindow, Scanner;

type
  TSWindow = class;


  { TSWindow (instance size 116, VMT 004519A0) }
  TSWindow = class(TDataModule)
  public
    published
    ScannerWindow: TAOWWindow; { +0044 }
    ScannerFrame: TAoWFrame; { +0048 }
    ScannerTab: TAOWTabPanel; { +004C }
    BuildingCheck: TAOWCheckBox; { +0050 }
    ArmyCheck: TAOWCheckBox; { +0054 }
    NaturalCheck: TAOWCheckBox; { +0058 }
    Scanner: TScanner; { +005C }
    STitleIcon: TAOWImage; { +0060 }
    STitleLabel: TAOWLabel; { +0064 }
    SMinIcon: TAOWButton; { +0068 }
    Help: TAOWButton; { +006C }
    Translator: TIvTranslator; { +0070 }
    public
    procedure ScannerTabChange;
    procedure ArmyCheckChange(Sender: TAOWCheckBox);
    procedure BuildingCheckChange(Sender: TAOWCheckBox);
    procedure NaturalCheckChange(Sender: TAOWCheckBox);
    procedure ScannerWindowResize;
    procedure SMinIconClick;
    procedure ScannerChangeTileBox;
    procedure ScannerTabMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure HelpClick;
  end;


implementation

uses AoWE, AoWWinMan, AoWExeForms, AOWMWindow, aowHelpWin;

procedure TSWindow.ScannerTabChange;
begin
  if AoWHSMap <> nil then
    case ScannerTab.Selected of
      0: begin Scanner.FUpdateStep := -1; AoWHSMap.ViewLevel(0); end;
      1: begin Scanner.FUpdateStep := -1; AoWHSMap.ViewLevel(1); end;
      2: begin Scanner.FUpdateStep := -1; AoWHSMap.ViewLevel(2); end;
    end;
end;

procedure TSWindow.ArmyCheckChange(Sender: TAOWCheckBox);
begin
  Scanner.SetArmies(ArmyCheck.Checked);
  if Sender.Checked then General.PlayButtonSound(1) else General.PlayButtonSound(2);
end;

procedure TSWindow.BuildingCheckChange(Sender: TAOWCheckBox);
begin
  Scanner.SetBuildings(BuildingCheck.Checked);
  if Sender.Checked then General.PlayButtonSound(1) else General.PlayButtonSound(2);
end;

procedure TSWindow.NaturalCheckChange(Sender: TAOWCheckBox);
begin
  Scanner.SetNaturals(NaturalCheck.Checked);
  if Sender.Checked then General.PlayButtonSound(1) else General.PlayButtonSound(2);
end;

procedure TSWindow.ScannerWindowResize;
begin
  with ScannerWindow do
  begin
    Alignment.RightOffset := FWinManager.WinWidth - WinWidth - WinLeft;
    Alignment.TopOffset := WinTop;
  end;
end;

procedure TSWindow.SMinIconClick;
begin
  General.PlayButtonSound(0);
  ScannerWindow.Visible := False;
end;

procedure TSWindow.ScannerChangeTileBox;
begin
  MWindow.MapViewer.SceneX := (SWindow.Scanner.FTLeft + 6) * 33;
  MWindow.MapViewer.SceneY := (SWindow.Scanner.FTTop + 6) * 33;
  if AoWHSMap.FSeatedPlayer <> -1 then
  begin
    SWindow.Scanner.SetTWidth(MWindow.MapViewer.SceneWidth div 32);
    SWindow.Scanner.SetTHeight(MWindow.MapViewer.SceneHeight div 32);
    SWindow.Scanner.SetTLeft(MWindow.MapViewer.SceneX div 32 - 6);
    SWindow.Scanner.SetTTop(MWindow.MapViewer.SceneY div 32 - 6);
  end;
end;

procedure TSWindow.ScannerTabMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin General.PlayButtonSound(0); end;

procedure TSWindow.HelpClick;
begin ShowHelp(501); end;

end.
