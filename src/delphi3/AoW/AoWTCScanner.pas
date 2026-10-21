unit AoWTCScanner;

{ Draft declarations of AoWTCScanner, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWFrame, AoWImage, AoWLabel, AoWWindow, Scanner;

type
  TTCScanner = class;


  { TTCScanner (instance size 96, VMT 00450958) }
  TTCScanner = class(TDataModule)
  public
    published
    TCScannerWin: TAOWWindow; { +0044 }
    ScannerFr: TAoWFrame; { +0048 }
    Scanner: TScanner; { +004C }
    STitleIcon: TAOWImage; { +0050 }
    STitleLabel: TAOWLabel; { +0054 }
    SMinIcon: TAOWButton; { +0058 }
    Translator: TIvTranslator; { +005C }
    public
    procedure ScannerChangeTileBox;  { draft }
    procedure TCScannerWinDrag;  { draft }
    procedure SMinIconClick;  { draft }
  end;


implementation

procedure TTCScanner.ScannerChangeTileBox;
begin end;

procedure TTCScanner.TCScannerWinDrag;
begin end;

procedure TTCScanner.SMinIconClick;
begin end;


end.
