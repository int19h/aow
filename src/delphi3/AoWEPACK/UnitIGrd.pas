unit UnitIGrd;

{ Draft declarations of UnitIGrd, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TUnitIndexGrid = class;


  { TUnitIndexGrid (instance size 488, VMT 557FF7A8) }
  TUnitIndexGrid = class(TCustomImageDrawGrid)
  public
    FUnitIndexList: TUnitIndexList; { $1DC }
    FSelectionControl: TUnitSelectionControl; { $1E0 }
    F_UnitIndexGrid_1E4: array[0..3] of Byte;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure DrawCell(ACol, ARow: Longint; ARect: Windows.TRect; AState: Grids.TGridDrawState); override;
    procedure SetShowUnitLevel(A1: Byte);  { draft }
    procedure GetUnitIndex;  { draft }
    procedure SetUnitIndexList(Value: TUnitIndexList);
    procedure SetUnitIndex;  { draft }
    procedure AddUnit;  { draft }
    procedure DeleteUnit;  { draft }
    procedure GetUnit;  { draft }
    procedure GetSelectedUnit;  { draft }
    procedure DblClick;  { draft }
    property SelectionEnabled; { $55801091 }
    property OnSelectCell; { $5580104D }
    property ColCount; { $55801165 }
    property Col; { $55801175 }
    property Row; { $55801194 }
  end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);  { draft }

implementation

constructor TUnitIndexGrid.Create(AOwner: Classes.TComponent);
begin end;

procedure TUnitIndexGrid.SetShowUnitLevel(A1: Byte);
begin end;

procedure TUnitIndexGrid.GetUnitIndex;
begin end;

procedure TUnitIndexGrid.SetUnitIndexList(Value: TUnitIndexList);
begin end;

procedure TUnitIndexGrid.SetUnitIndex;
begin end;

procedure TUnitIndexGrid.DrawCell(ACol, ARow: Longint; ARect: Windows.TRect; AState: Grids.TGridDrawState);
begin end;

procedure TUnitIndexGrid.AddUnit;
begin end;

procedure TUnitIndexGrid.DeleteUnit;
begin end;

procedure TUnitIndexGrid.GetUnit;
begin end;

procedure TUnitIndexGrid.GetSelectedUnit;
begin end;

procedure TUnitIndexGrid.DblClick;
begin end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);
begin end;


initialization
finalization

end.
