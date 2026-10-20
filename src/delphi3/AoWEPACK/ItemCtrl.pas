unit ItemCtrl;

{ Draft declarations of ItemCtrl, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TItemControlGrid = class;


  { TItemControlGrid (instance size 504, VMT 5580795C) }
  TItemControlGrid = class(TCustomImageDrawGrid)
  public
    F_ItemControlGrid_1DC: Integer;
    F_ItemControlGrid_1E0: Integer;
    F_ItemControlGrid_1E4: array[0..19] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure DrawCell(ACol, ARow: Longint; ARect: Windows.TRect; AState: Grids.TGridDrawState); override;
    procedure DelCell; override;
    procedure MouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer);  { draft }
    procedure ItemChanged;  { draft }
    procedure ItemControlChanged;  { draft }
    procedure SetAoWHSMap(A1: Integer);  { draft }
    procedure SortOnName;  { draft }
    procedure SortOnType;  { draft }
    procedure GetSelectedItem;  { draft }
    procedure GetItem(A1: Integer);  { draft }
    procedure UpdateItems;  { draft }
    procedure Unselect;  { draft }
    procedure EditItemDone(A1: Byte; A2: Integer);  { draft }
    procedure DeleteItem;  { draft }
    procedure RemoveItemFromMap;  { draft }
  end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);  { draft }

implementation

constructor TItemControlGrid.Create(AOwner: Classes.TComponent);
begin end;

destructor TItemControlGrid.Destroy;
begin end;

procedure TItemControlGrid.MouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer);
begin end;

procedure TItemControlGrid.ItemChanged;
begin end;

procedure TItemControlGrid.ItemControlChanged;
begin end;

procedure TItemControlGrid.SetAoWHSMap(A1: Integer);
begin end;

procedure TItemControlGrid.SortOnName;
begin end;

procedure TItemControlGrid.SortOnType;
begin end;

procedure TItemControlGrid.DelCell;
begin end;

procedure TItemControlGrid.GetSelectedItem;
begin end;

procedure TItemControlGrid.GetItem(A1: Integer);
begin end;

procedure TItemControlGrid.UpdateItems;
begin end;

procedure TItemControlGrid.DrawCell(ACol, ARow: Longint; ARect: Windows.TRect; AState: Grids.TGridDrawState);
begin end;

procedure TItemControlGrid.Unselect;
begin end;

procedure TItemControlGrid.EditItemDone(A1: Byte; A2: Integer);
begin end;

procedure TItemControlGrid.DeleteItem;
begin end;

procedure TItemControlGrid.RemoveItemFromMap;
begin end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);
begin end;


initialization
finalization

end.
