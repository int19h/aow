unit UnitIGrd;

{ Draft declarations of UnitIGrd, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TUnitIndexGrid = class;


  { TUnitIndexGrid (instance size 488, VMT 557FF7A8) }
  TUnitIndexGrid = class(TCustomImageDrawGrid)
  public
    F_UnitIndexGrid_1DC: Integer;
    F_UnitIndexGrid_1E0: array[0..7] of Byte;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure DrawCell(ACol, ARow: Longint; ARect: Windows.TRect; AState: Grids.TGridDrawState); override;
    procedure SetShowUnitLevel(A1: Byte);  { draft }
    procedure GetUnitIndex;  { draft }
    procedure SetUnitIndexList(A1: Integer);  { draft }
    procedure SetUnitIndex;  { draft }
    procedure AddUnit;  { draft }
    procedure DeleteUnit;  { draft }
    procedure GetUnit;  { draft }
    procedure GetSelectedUnit;  { draft }
    procedure DblClick;  { draft }
  end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);  { draft }

implementation

constructor TUnitIndexGrid.Create(AOwner: Classes.TComponent);
begin end;

procedure TUnitIndexGrid.SetShowUnitLevel(A1: Byte);
begin end;

procedure TUnitIndexGrid.GetUnitIndex;
begin end;

procedure TUnitIndexGrid.SetUnitIndexList(A1: Integer);
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
