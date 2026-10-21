unit ScannerFlt;

{ Draft declarations of ScannerFlt, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AOWInterfaceImgLib, AOWWinManager, AoWWindow, MapCtrl, Scanner;

type
  TScannerFloater = class;


  { TScannerFloater (instance size 528, VMT 00420E84) }
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
    F_ScannerFloater_20C: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure DisplayResize;  { draft }
    procedure DisplayMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure DisplayMouseMove(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure DisplayMouseUp(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure TheMapMapChanged(A1: Integer);  { draft }
    procedure DisplayBltSurface;  { draft }
    procedure FormClose;  { draft }
    procedure TheMapViewPortChange;  { draft }
    procedure ScannerChangeTileBox;  { draft }
    procedure TheMapScannerIconsChanged;  { draft }
  end;


implementation

constructor TScannerFloater.Create(AOwner: Classes.TComponent);
begin end;

destructor TScannerFloater.Destroy;
begin end;

procedure TScannerFloater.DisplayResize;
begin end;

procedure TScannerFloater.DisplayMouseDown(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TScannerFloater.DisplayMouseMove(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TScannerFloater.DisplayMouseUp(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TScannerFloater.TheMapMapChanged(A1: Integer);
begin end;

procedure TScannerFloater.DisplayBltSurface;
begin end;

procedure TScannerFloater.FormClose;
begin end;

procedure TScannerFloater.TheMapViewPortChange;
begin end;

procedure TScannerFloater.ScannerChangeTileBox;
begin end;

procedure TScannerFloater.TheMapScannerIconsChanged;
begin end;


end.
