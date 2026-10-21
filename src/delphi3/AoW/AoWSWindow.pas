unit AoWSWindow;

{ Draft declarations of AoWSWindow, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

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
    procedure ScannerTabChange;  { draft }
    procedure ArmyCheckChange(A1: Integer);  { draft }
    procedure BuildingCheckChange(A1: Integer);  { draft }
    procedure NaturalCheckChange(A1: Integer);  { draft }
    procedure ScannerWindowResize;  { draft }
    procedure SMinIconClick;  { draft }
    procedure ScannerChangeTileBox;  { draft }
    procedure ScannerTabMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure HelpClick;  { draft }
  end;


implementation

procedure TSWindow.ScannerTabChange;
begin end;

procedure TSWindow.ArmyCheckChange(A1: Integer);
begin end;

procedure TSWindow.BuildingCheckChange(A1: Integer);
begin end;

procedure TSWindow.NaturalCheckChange(A1: Integer);
begin end;

procedure TSWindow.ScannerWindowResize;
begin end;

procedure TSWindow.SMinIconClick;
begin end;

procedure TSWindow.ScannerChangeTileBox;
begin end;

procedure TSWindow.ScannerTabMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TSWindow.HelpClick;
begin end;


end.
