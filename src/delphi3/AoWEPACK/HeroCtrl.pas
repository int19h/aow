unit HeroCtrl;

{ Draft declarations of HeroCtrl, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  THeroControlGrid = class;


  { THeroControlGrid (instance size 504, VMT 55808AFC) }
  THeroControlGrid = class(TCustomImageDrawGrid)
  public
    F_HeroControlGrid_1DC: Integer;
    F_HeroControlGrid_1E0: array[0..3] of Byte;
    F_HeroControlGrid_1E4: Integer;
    F_HeroControlGrid_1E8: array[0..15] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure DrawCell(ACol, ARow: Longint; ARect: Windows.TRect; AState: Grids.TGridDrawState); override;
    procedure MouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer);  { draft }
    procedure SetAoWHSMap(A1: Integer);  { draft }
    procedure HeroControlChanged;  { draft }
    procedure HeroChanged;  { draft }
    procedure GetHero(A1: Integer);  { draft }
    procedure GetSelectedHero;  { draft }
    procedure SetSelectedHero;  { draft }
    procedure Unselect;  { draft }
    procedure UpdateHeroes(A1: Integer; A2: Integer);  { draft }
    procedure SortOnName;  { draft }
    procedure SortOnLevel;  { draft }
    procedure DeleteHero;  { draft }
    procedure RemoveFromMap;  { draft }
  end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);  { draft }

implementation

constructor THeroControlGrid.Create(AOwner: Classes.TComponent);
begin end;

destructor THeroControlGrid.Destroy;
begin end;

procedure THeroControlGrid.MouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer);
begin end;

procedure THeroControlGrid.SetAoWHSMap(A1: Integer);
begin end;

procedure THeroControlGrid.HeroControlChanged;
begin end;

procedure THeroControlGrid.HeroChanged;
begin end;

procedure THeroControlGrid.GetHero(A1: Integer);
begin end;

procedure THeroControlGrid.GetSelectedHero;
begin end;

procedure THeroControlGrid.SetSelectedHero;
begin end;

procedure THeroControlGrid.Unselect;
begin end;

procedure THeroControlGrid.UpdateHeroes(A1: Integer; A2: Integer);
begin end;

procedure THeroControlGrid.SortOnName;
begin end;

procedure THeroControlGrid.SortOnLevel;
begin end;

procedure THeroControlGrid.DrawCell(ACol, ARow: Longint; ARect: Windows.TRect; AState: Grids.TGridDrawState);
begin end;

procedure THeroControlGrid.DeleteHero;
begin end;

procedure THeroControlGrid.RemoveFromMap;
begin end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);
begin end;


initialization
finalization

end.
