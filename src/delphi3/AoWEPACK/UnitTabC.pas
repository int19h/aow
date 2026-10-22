unit UnitTabC;

{ Unit selection tabs recovered from AoWEPACK.dpl. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, GFXE, ImageLib, Sound, NetworkE, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, UnitIGrd, AoWE;

type
  TUnitTabControl = class;
  TOnSelectUnitEvent = procedure(Sender: TObject; UnitIndex: Integer) of object;


  { TUnitTabControl (instance size 336, VMT 55800EA4):
    $140 selection control, $144 unit index grid, $148 selection event. }
  TUnitTabControl = class(TTabControl)
  public
    FSelectionControl: TUnitSelectionControl; { $140 }
    FUnitIndexGrid: TUnitIndexGrid; { $144 }
    FOnSelectUnit: TOnSelectUnitEvent; { $148 }
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure Change; override;
    procedure SetUnitIndexGrid(Value: TUnitIndexGrid);
    procedure UnitIndexGridSelectCell(Sender: TObject; ACol, ARow: Longint; var CanSelect: Boolean);
    procedure UpdateUnitIndexGrid;
    procedure UpdateSelection;
  published property UnitIndexGrid: TUnitIndexGrid read FUnitIndexGrid write SetUnitIndexGrid; property OnSelectUnit: TOnSelectUnitEvent read FOnSelectUnit write FOnSelectUnit; end;

procedure Register;

implementation

constructor TUnitTabControl.Create(AOwner: Classes.TComponent);
begin
  inherited Create(AOwner);
  if not (csDesigning in ComponentState) then
    FSelectionControl := TUnitSelectionControl.Create;
end;

destructor TUnitTabControl.Destroy;
begin
  FSelectionControl.Free;
  inherited Destroy;
end;

procedure TUnitTabControl.Change;
begin
  UpdateUnitIndexGrid;
  inherited Change;
end;

procedure TUnitTabControl.SetUnitIndexGrid(Value: TUnitIndexGrid);
begin
  FUnitIndexGrid := Value;
  if Value <> nil then
  begin
    FUnitIndexGrid.OnSelectCell := UnitIndexGridSelectCell;
    FUnitIndexGrid.FSelectionControl := FSelectionControl;
  end;
end;

procedure TUnitTabControl.UnitIndexGridSelectCell(Sender: TObject; ACol, ARow: Longint; var CanSelect: Boolean); { Near miss: three variants retain a different index/list register allocation. }
var
  Index: Integer;
  List: TUnitIndexList;
begin
  Index := FUnitIndexGrid.ImageIndex(ACol, ARow);
  FUnitIndexGrid.SelectionEnabled := True;
  List := FUnitIndexGrid.FUnitIndexList;
  if List <> nil then FSelectionControl.SetSelectedUnitIndex(List[Index]);
  if Assigned(FOnSelectUnit) then FOnSelectUnit(Self, FSelectionControl.FSelectedUnitIndex);
end;

procedure TUnitTabControl.UpdateUnitIndexGrid;
var
  Index: Integer;
begin
  if FUnitIndexGrid <> nil then
  begin
    if TabIndex >= 0 then
    begin
      Index := Integer(Tabs.Objects[TabIndex]);
      FUnitIndexGrid.SetUnitIndexList(FSelectionControl.GetUnitCategoryList(Index));
      if FSelectionControl.FSelectedUnitIndex <> -1 then
      begin
        Index := FUnitIndexGrid.FUnitIndexList.IndexOf(FSelectionControl.FSelectedUnitIndex);
        if Index <> -1 then
        begin
          FUnitIndexGrid.Col := Index mod FUnitIndexGrid.ColCount;
          FUnitIndexGrid.Row := Index div FUnitIndexGrid.ColCount;
          FUnitIndexGrid.SelectionEnabled := True;
        end
        else FUnitIndexGrid.SelectionEnabled := False;
      end;
      if FSelectionControl.FSelectedUnitIndex = -1 then
        FUnitIndexGrid.SelectionEnabled := False;
    end
    else FUnitIndexGrid.SetUnitIndexList(nil);
    Invalidate;
  end;
end;

procedure TUnitTabControl.UpdateSelection;
begin
  FSelectionControl.UpdateSelection;
  Tabs := FSelectionControl;
  UpdateUnitIndexGrid;
end;

procedure Register;
begin
  RegisterComponents('AoWEngine', [TUnitTabControl]);
end;


initialization
finalization

end.
