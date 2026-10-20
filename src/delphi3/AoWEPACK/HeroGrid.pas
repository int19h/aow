unit HeroGrid;

{ Draft declarations of HeroGrid, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  THeroGrid = class;


  { THeroGrid (instance size 496, VMT 558012E8) }
  THeroGrid = class(TCustomImageDrawGrid)
  public
    F_HeroGrid_1DC: Integer;
    F_HeroGrid_1E0: array[0..7] of Byte;
    F_HeroGrid_1E8: Integer;
    F_HeroGrid_1EC: array[0..3] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure DrawCell(ACol, ARow: Longint; ARect: Windows.TRect; AState: Grids.TGridDrawState); override;
    procedure DeleteCell; override;
    procedure DelCell; override;
    procedure GetHero(A1: Integer);  { draft }
    procedure GetSelectedHero;  { draft }
    procedure SetSelectedHero;  { draft }
    procedure SortHeroes(A1: Byte);  { draft }
    procedure UpdateHeroes;  { draft }
    procedure SortOnName;  { draft }
    procedure SortOnLevel;  { draft }
    procedure HeroesUpdated;  { draft }
    procedure SetHeroes(A1: Integer);  { draft }
    procedure DeleteHero;  { draft }
    procedure DeleteSelectedHero;  { draft }
  end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);  { draft }

implementation

constructor THeroGrid.Create(AOwner: Classes.TComponent);
begin end;

destructor THeroGrid.Destroy;
begin end;

procedure THeroGrid.DeleteCell;
begin end;

procedure THeroGrid.DelCell;
begin end;

procedure THeroGrid.GetHero(A1: Integer);
begin end;

procedure THeroGrid.GetSelectedHero;
begin end;

procedure THeroGrid.SetSelectedHero;
begin end;

procedure THeroGrid.SortHeroes(A1: Byte);
begin end;

procedure THeroGrid.UpdateHeroes;
begin end;

procedure THeroGrid.SortOnName;
begin end;

procedure THeroGrid.SortOnLevel;
begin end;

procedure THeroGrid.HeroesUpdated;
begin end;

procedure THeroGrid.SetHeroes(A1: Integer);
begin end;

procedure THeroGrid.DrawCell(ACol, ARow: Longint; ARect: Windows.TRect; AState: Grids.TGridDrawState);
begin end;

procedure THeroGrid.DeleteHero;
begin end;

procedure THeroGrid.DeleteSelectedHero;
begin end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);
begin end;


initialization
finalization

end.
