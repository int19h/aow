unit UnitGrid;

{ Draft declarations of UnitGrid, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TUnitGrid = class;


  { TUnitGrid (instance size 500, VMT 55802E30) }
  TUnitGrid = class(TCustomImageDrawGrid)
  public
    F_UnitGrid_1DC: array[0..3] of Byte;
    F_UnitGrid_1E0: Integer;
    F_UnitGrid_1E4: array[0..0] of Byte;
    F_UnitGrid_1E5: Byte;
    F_UnitGrid_1E6: array[0..9] of Byte;
    F_UnitGrid_1F0: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure DrawCell(ACol, ARow: Longint; ARect: Windows.TRect; AState: Grids.TGridDrawState); override;
    procedure SetShowUnitLevel(A1: Byte);  { draft }
    procedure SetUnits(A1: Integer);  { draft }
    procedure GetUnit;  { draft }
    procedure GetSelectedUnit;  { draft }
    procedure AddUnit;  { draft }
    procedure DeleteUnit;  { draft }
    procedure EditUnitDone(A1: Byte; A2: Integer);  { draft }
    procedure DblClick;  { draft }
  end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);  { draft }

implementation

constructor TUnitGrid.Create(AOwner: Classes.TComponent);
begin end;

destructor TUnitGrid.Destroy;
begin end;

procedure TUnitGrid.SetShowUnitLevel(A1: Byte);
begin end;

procedure TUnitGrid.SetUnits(A1: Integer);
begin end;

procedure TUnitGrid.GetUnit;
begin end;

procedure TUnitGrid.GetSelectedUnit;
begin end;

procedure TUnitGrid.DrawCell(ACol, ARow: Longint; ARect: Windows.TRect; AState: Grids.TGridDrawState);
begin end;

procedure TUnitGrid.AddUnit;
begin end;

procedure TUnitGrid.DeleteUnit;
begin end;

procedure TUnitGrid.EditUnitDone(A1: Byte; A2: Integer);
begin end;

procedure TUnitGrid.DblClick;
begin end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);
begin end;


initialization
finalization

end.
