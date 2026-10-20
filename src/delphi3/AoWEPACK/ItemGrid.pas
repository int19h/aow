unit ItemGrid;

{ Draft declarations of ItemGrid, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TItemGrid = class;


  { TItemGrid (instance size 496, VMT 55802170) }
  TItemGrid = class(TCustomImageDrawGrid)
  public
    F_ItemGrid_1DC: array[0..3] of Byte;
    F_ItemGrid_1E0: Integer;
    F_ItemGrid_1E4: Integer;
    F_ItemGrid_1E8: Integer;
    F_ItemGrid_1EC: array[0..3] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure DrawCell(ACol, ARow: Longint; ARect: Windows.TRect; AState: Grids.TGridDrawState); override;
    procedure DelCell; override;
    procedure GetSelectedItem;  { draft }
    procedure GetItem(A1: Integer);  { draft }
    procedure SetItems(A1: Integer);  { draft }
    procedure UpdateItems;  { draft }
    procedure SortOnName;  { draft }
    procedure SortOnType;  { draft }
    procedure EditItemDone(A1: Byte; A2: Integer);  { draft }
    procedure CreateNewItem;  { draft }
    procedure AddItem(A1: Integer);  { draft }
    procedure DeleteItem;  { draft }
  end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);  { draft }

implementation

constructor TItemGrid.Create(AOwner: Classes.TComponent);
begin end;

destructor TItemGrid.Destroy;
begin end;

procedure TItemGrid.DelCell;
begin end;

procedure TItemGrid.GetSelectedItem;
begin end;

procedure TItemGrid.GetItem(A1: Integer);
begin end;

procedure TItemGrid.SetItems(A1: Integer);
begin end;

procedure TItemGrid.UpdateItems;
begin end;

procedure TItemGrid.SortOnName;
begin end;

procedure TItemGrid.SortOnType;
begin end;

procedure TItemGrid.DrawCell(ACol, ARow: Longint; ARect: Windows.TRect; AState: Grids.TGridDrawState);
begin end;

procedure TItemGrid.EditItemDone(A1: Byte; A2: Integer);
begin end;

procedure TItemGrid.CreateNewItem;
begin end;

procedure TItemGrid.AddItem(A1: Integer);
begin end;

procedure TItemGrid.DeleteItem;
begin end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);
begin end;


initialization
finalization

end.
