unit ScannerFlt;

{ Draft declarations of ScannerFlt, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Scanner input and invalidation follow the original viewport calculations. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AOWInterfaceImgLib, AOWWinManager, AoWWindow, MapCtrl, Scanner, AoWE;

type
  TScannerFloater = class;


  { TScannerFloater: instance size $210, VMT 00420E84; published controls
    $1DC..$208, $20C FMap is the editor map observed by the scanner. }
  TScannerFloater = class(TForm)
  public
    published
    Display: TDisplay; { +01DC }
    WindowsDC: TWindows16DC; { +01E0 }
    Manager: TAOWWinManager; { +01E4 }
    Dlg: TAOWWindow; { +01E8 }
    Scanner: TScanner; { +01EC }
    TheMap: TAoWMapControl; { +01F0 }
    ScanTiles: TInterfaceIL; { +01F4 }
    ScanFog: TInterfaceIL; { +01F8 }
    ScanHiLites: TInterfaceIL; { +01FC }
    ScanObj: TInterfaceIL; { +0200 }
    ScanWin: TInterfaceIL; { +0204 }
    Translator: TIvTranslator; { +0208 }
    public
    FMap: TAoWHSMap; { $20C }
    procedure SetMap(Map: TAoWHSMap);
    procedure UpdateLevel;
    procedure ShowScanner;
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    published procedure DisplayResize(Sender: TObject); public
    published procedure DisplayMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); public
    published procedure DisplayMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer); public
    published procedure DisplayMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); public
    published procedure TheMapMapChanged(const Info: TMapChangedInfo); public
    published procedure DisplayBltSurface(Sender: TObject); public
    published procedure FormClose(Sender: TObject; var Action: TCloseAction); public
    published procedure TheMapViewPortChange(Sender: TObject); public
    published procedure ScannerChangeTileBox(Sender: TObject); public
    published procedure TheMapScannerIconsChanged(Sender: TObject); public
  end;


var
  ScannerFloater: TScannerFloater;

implementation

uses MDIForm;

{$R+,Q+}

procedure TScannerFloater.SetMap(Map: TAoWHSMap);
begin
  FMap := Map;
  if Map <> nil then
  begin
    Map.SetExplorationEnabled(False);
    FMap.SetFogEnabled(False);
    FMap.SetSeatedPlayer(0);
    Scanner.SetMap(AoWHSMap);
    with Manager do
    begin
      WinWidth := Display.BackSurfaceWidth;
      WinHeight := Display.BackSurfaceHeight;
      ReAlign;
    end;
    UpdateLevel;
    TheMapViewPortChange(Self);
  end
  else Hide;
  Display.Invalidate;
end;

procedure TScannerFloater.UpdateLevel;
var Control: TScanner;
begin
  if AoWHSMap <> nil then
  begin
    Scanner.SetLevel(AoWHSMap.MapContainer.MapLevels[AoWHSMap.ViewL]);
    Control := Scanner;
    with Control do
    begin
      FPreviousWidth := 0;
      FIncremental := False;
      FDrawn := False;
      SetSize;
    end;
    Scanner.FUpdateStep := -1;
    Scanner.DrawMap(0, 0, 999, 999);
    Display.Invalidate;
  end;
end;

procedure TScannerFloater.ShowScanner;
begin
  if FMap <> nil then Show;
end;

constructor TScannerFloater.Create(AOwner: Classes.TComponent);
begin
  inherited Create(AOwner);
  Left := 0;
  Top := 90;
  Width := 170;
  Height := 200;
end;


destructor TScannerFloater.Destroy;
begin
  inherited Destroy;
end;


procedure TScannerFloater.DisplayResize(Sender: TObject);
begin
  with Manager do
  begin
    WinWidth := Display.BackSurfaceWidth;
    WinHeight := Display.BackSurfaceHeight;
    ReAlign;
  end;
  UpdateLevel;
end;


procedure TScannerFloater.DisplayMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Manager.CheckMouseDown(Button, Shift, X, Y);
end;


procedure TScannerFloater.DisplayMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  Manager.CheckMouseMove(Shift, X, Y);
end;


procedure TScannerFloater.DisplayMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Manager.CheckMouseUp(Button, Shift, X, Y);
end;


procedure TScannerFloater.TheMapMapChanged(const Info: TMapChangedInfo);
begin
  if Info.MapLevel = Scanner.FLevel then
    Scanner.DrawMap(Info.Bounds.Left - 6,
      Info.Bounds.Top - 6,
      Info.Bounds.Right - Info.Bounds.Left,
      Info.Bounds.Bottom - Info.Bounds.Top);
  Display.Invalidate;
end;


procedure TScannerFloater.DisplayBltSurface(Sender: TObject);
var DC: TAbstractDC;
begin
  DC := Display.ActiveDC;
  if DC <> nil then with DC do Manager.DrawSurface(GetSurface(1));
end;


procedure TScannerFloater.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FMap <> nil then MainForm.ScannerItem.Checked := False;
end;


procedure TScannerFloater.TheMapViewPortChange(Sender: TObject);
begin
  if FMap <> nil then
  begin
    Scanner.SetTLeft(FMap.ViewXhx - 6);
    Scanner.SetTTop(FMap.ViewYhx - 6);
    Scanner.SetTWidth(FMap.ViewWidthHX);
    Scanner.SetTHeight(FMap.ViewHeightHX);
    if FMap.MapContainer.MapLevels[FMap.ViewL] <> Scanner.FLevel then UpdateLevel;
  end;
  Display.Invalidate;
end;

procedure TScannerFloater.ScannerChangeTileBox(Sender: TObject);
begin
  if FMap <> nil then
  begin
    MainForm.HSMEdit.CenterView(Scanner.FTLeft + Scanner.FTWidth div 2 + 6,
      Scanner.FTTop + Scanner.FTHeight div 2 + 6, FMap.ViewL);
    Display.ExecuteBltSurfaceEvent;
  end;
end;


procedure TScannerFloater.TheMapScannerIconsChanged(Sender: TObject);
begin
  Scanner.SetObDrawn(False);
  Display.Invalidate;
end;



end.
