unit AoWTCScanner;

{ Draft declarations of AoWTCScanner, from AoW.exe.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
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
    published procedure ScannerChangeTileBox; public  { draft }
    published procedure TCScannerWinDrag; public  { draft }
    published procedure SMinIconClick; public  { draft }
  end;


implementation

uses AoWE, AoWWinMan, E3Globals;

procedure TTCScanner.ScannerChangeTileBox;
begin
  MWindow.MapViewer.SceneX := (Scanner.FTLeft + 6) * 33;
  MWindow.MapViewer.SceneY := (Scanner.FTTop + 6) * 33;
  if AoWHSMap.FSeatedPlayer <> -1 then
  begin
    Scanner.SetTWidth(MWindow.MapViewer.SceneWidth div 32);
    Scanner.SetTHeight(MWindow.MapViewer.SceneHeight div 32);
    Scanner.SetTLeft(MWindow.MapViewer.SceneX div 32 - 6);
    Scanner.SetTTop(MWindow.MapViewer.SceneY div 32 - 6);
  end;
end;

procedure TTCScanner.TCScannerWinDrag;
begin
  with TCScannerWin do
  begin
    Alignment.RightOffset := WinManager.WinWidth - WinLeft - WinWidth;
    Alignment.TopOffset := WinTop;
  end;
end;

procedure TTCScanner.SMinIconClick;
begin
  General.PlayButtonSound(0);
  TCScannerWin.Visible := False;
end;


end.
