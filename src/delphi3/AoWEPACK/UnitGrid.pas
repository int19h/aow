unit UnitGrid;

{ UnitGrid, from AoWEPACK.dpl. Recovered unit selection, drawing and editing. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, GFXE, ImageLib, Sound, NetworkE, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, AoWE;

type
  TUnitGrid = class;


  { TUnitGrid (instance size 500, VMT 55802E30): $1DC FSelectionControl,
    $1E0 FUnits, $1E4 FEditEnabled, $1E5 FShowUnitLevel, $1F0 FMemoryStream. }
  TUnitGrid = class(TCustomImageDrawGrid)
  public
    FSelectionControl: TUnitSelectionControl; { $1DC }
    FUnits: TUnitList; { $1E0 }
    FEditEnabled: Boolean; { $1E4 }
    FShowUnitLevel: Boolean; { $1E5 }
    F_UnitGrid_1E6: array[0..9] of Byte;
    FMemoryStream: TMemoryStream; { $1F0 }
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure DrawCell(ACol, ARow: Longint; ARect: Windows.TRect; AState: Grids.TGridDrawState); override;
    procedure SetShowUnitLevel(Value: Boolean); published property SelectionEnabled; public { AoWEd 0041B03F }
    procedure SetUnits(Value: TUnitList);
    function GetUnit(ACol, ARow: Integer): TAbstractUnit;
    function GetSelectedUnit: TAbstractUnit;
    procedure AddUnit;
    procedure DeleteUnit;
    procedure EditUnitDone(EditResult: TEditResult; Obj: TEObject);
    procedure DblClick; override;
  published property ShowUnitLevel: Boolean read FShowUnitLevel write SetShowUnitLevel; property EditEnabled: Boolean read FEditEnabled write FEditEnabled; property OnDblClick; property OnSelectCell; property FocusColor; property Align; property BltMode; property OnCellUpdated; property ScaleX; property ScaleY; property Color; property ScrollBars; property DefaultRowHeight; property DefaultColWidth; property GridLineWidth; property ColCount; property RowCount; property PopupMenu; property EditMode; property Options; property GrowDirection; property MinRowCount; property MinColCount; property MaxRowCount; property MaxColCount; property ShowGridIndex; property Font; end;

procedure Register;

implementation

uses UnitIDlg;

type
  PAoWSet = ^TAoWHSSet;
  PAoWEngine = ^TAoWEngine;
const
  WorldSet: PAoWSet = @AoWE.AoWHSSet;
  WorldEngine: PAoWEngine = @AoWE.AoWEngine;

constructor TUnitGrid.Create(AOwner: Classes.TComponent);
begin
  inherited Create(AOwner);
  FMemoryStream := TMemoryStream.Create;
  RowCount := 1;
  ColCount := 8;
  DefaultColWidth := 48;
  DefaultRowHeight := 48;
end;

destructor TUnitGrid.Destroy;
begin
  FMemoryStream.Free;
  FMemoryStream := nil;
  inherited Destroy;
end;

procedure TUnitGrid.SetShowUnitLevel(Value: Boolean);
begin
  FShowUnitLevel := Value;
  Invalidate;
end;

procedure TUnitGrid.SetUnits(Value: TUnitList);
var Units: TUnitList; begin
  Units := Value; FUnits := Units;
  { Original assumes Value is non-nil. }
  Count := Units.Count;
  Invalidate;
end;

function TUnitGrid.GetUnit(ACol, ARow: Integer): TAbstractUnit;
var Index: Integer;
begin
  Index := ImageIndex(ACol, ARow);
  { Original leaves negative indices unchecked in both getters. }
  if (FUnits <> nil) and (Index < FUnits.Count) then Result := FUnits.GetUnit(Index)
  else Result := nil;
end;

function TUnitGrid.GetSelectedUnit: TAbstractUnit;
var Index: Integer;
begin
  Index := ImageIndex(Col, Row);
  if (FUnits <> nil) and (Index < FUnits.Count) then Result := FUnits.GetUnit(Index)
  else Result := nil;
end;

procedure TUnitGrid.DrawCell(ACol, ARow: Longint; ARect: Windows.TRect; AState: Grids.TGridDrawState);
var
  Index, GFXIndex: Integer;
  Sequence: TImageSequence;
  Level: string;
begin
  Index := ImageIndex(ACol, ARow);
  if (FUnits <> nil) and (Index < FUnits.Count) and (FUnits.GetUnit(Index) <> nil) then
  begin
    GFXIndex := FUnits.GetUnit(Index).GetUnitGFXResourceIndex;
    WorldSet^.FUnitGFXResources.GetUnitGFXResource(GFXIndex).AddRef;
    Sequence := WorldSet^.FUnitGFXResources.GetUnitGFXResource(GFXIndex).FSequences.GetImageSequence(2);
    if Sequence <> nil then
      BltImageSequence(Sequence, Canvas.Handle, 8, 16, ARect, 0, $610000);
    WorldSet^.FUnitGFXResources.GetUnitGFXResource(GFXIndex).Release;
    if FShowUnitLevel then
    begin
      Level := IntToStr(FUnits.GetUnit(Index).GetUnitLevel);
      Canvas.Brush.Style := bsClear;
      Canvas.Font.Color := Font.Color;
      Inc(ARect.Left, 3);
      Inc(ARect.Top, 2);
      DrawText(Canvas.Handle, PChar(Level), Length(Level), ARect, $50);
      Dec(ARect.Left, 3);
      Dec(ARect.Top, 2);
    end;
  end
  else
  begin
    Canvas.Brush.Color := Color;
    Canvas.FillRect(ARect);
  end;
  inherited DrawCell(ACol, ARow, ARect, AState);
end;

procedure TUnitGrid.AddUnit;
var
  MaxCount: Integer;
  AUnit: TUnit;
  Hero: THero;
begin
  MaxCount := MaxRowCount * MaxColCount;
  if (FSelectionControl <> nil) and (FUnits <> nil) then
    if (MaxCount = 0) or (MaxCount > FUnits.Count) then
      if FSelectionControl.FSelectedUnitIndex <> -1 then
      begin
        AUnit := TUnit.Create(nil);
        AUnit.SetUnitResource(WorldSet^.FUnitResources.GetUnitResource(FSelectionControl.FSelectedUnitIndex));
        if FUnits.CanAddUnit(AUnit) then
        begin
          FUnits.AddUnit(AUnit);
          Count := FUnits.Count;
          SelectCell(Col, Row);
          Invalidate;
        end
        else MessageBeep(0);
        AUnit.Release;
      end
      else
      begin
        Hero := FSelectionControl.FSelectedHero;
        if (Hero <> nil) and FUnits.CanAddUnit(Hero) then
        begin
          FUnits.AddUnit(FSelectionControl.FSelectedHero);
          Count := FUnits.Count;
          SelectCell(Col, Row);
          Invalidate;
        end;
      end;
end;

procedure TUnitGrid.DeleteUnit;
var Index: Integer;
begin
  Index := ImageIndex(Col, Row);
  if (FUnits <> nil) and (Index < FUnits.Count) and
    (FUnits.GetUnit(Index) <> nil) and FUnits.CanDeleteUnit(FUnits.GetUnit(Index)) then
  begin
    FUnits.DeleteUnit(FUnits.GetUnit(Index));
    Count := FUnits.Count;
    SelectCell(Col, Row);
    Invalidate;
  end
  else MessageBeep(0);
end;

procedure TUnitGrid.EditUnitDone(EditResult: TEditResult; Obj: TEObject);
begin
  if EditResult = erCancel then
  begin
    FMemoryStream.Position := 0;
    WorldEngine^.ReadEObject(FMemoryStream, Obj, nil);
    FMemoryStream.Clear;
  end
  else FMemoryStream.Clear;
  Invalidate;
end;

procedure TUnitGrid.DblClick;
var Dlg: TUnitInfoDlg;
begin
  if GetSelectedUnit <> nil then
  begin
    Dlg := TUnitInfoDlg.Create(Application);
    Dlg.ShowUnit(GetSelectedUnit);
    Dlg.Free;
  end;
end;

procedure Register;
begin
  RegisterComponents('AoWEngine', [TUnitGrid]);
end;

initialization
finalization

end.
