unit UnitIGrd;

{ UnitIGrd, from AoWEPACK.dpl. Recovered unit-index selection and drawing. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TUnitIndexGrid = class;


  { TUnitIndexGrid (instance size 488, VMT 557FF7A8): $1DC FUnitIndexList,
    $1E0 FSelectionControl, $1E4 FShowUnitLevel, $1E5 FDoubleUnitsEnabled, $1E6 FSorted. }
  TUnitIndexGrid = class(TCustomImageDrawGrid)
  public
    FUnitIndexList: TUnitIndexList; { $1DC }
    FSelectionControl: TUnitSelectionControl; { $1E0 }
    FShowUnitLevel: Boolean; { $1E4 }
    FDoubleUnitsEnabled: Boolean; { $1E5 }
    FSorted: Boolean; { $1E6 }
    FReserved1E7: Byte;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure DrawCell(ACol, ARow: Longint; ARect: Windows.TRect; AState: Grids.TGridDrawState); override;
    procedure SetShowUnitLevel(Value: Boolean);
    function GetUnitIndex(Index: Integer): Integer;
    procedure SetUnitIndexList(Value: TUnitIndexList);
    procedure SetUnitIndex(Index, Value: Integer);
    procedure AddUnit;
    procedure DeleteUnit;
    function GetUnit(ACol, ARow: Integer): Integer;
    function GetSelectedUnit: Integer;
    procedure DblClick; override;
    property SelectionEnabled; { $55801091 }
    property OnSelectCell; { $5580104D }
    property ColCount; { $55801165 }
    property Col; { $55801175 }
    property Row; { $55801194 }
  end;

procedure Register;

implementation

uses UnitIDlg;

type PAoWSet = ^TAoWHSSet;
const WorldSet: PAoWSet = @AoWE.AoWHSSet;

constructor TUnitIndexGrid.Create(AOwner: Classes.TComponent);
begin
  inherited Create(AOwner);
  RowCount := 1;
  ColCount := 8;
  FShowUnitLevel := True;
  DefaultColWidth := 48;
  DefaultRowHeight := 48;
  Font.Color := clRed;
  GrowDirection := ilHorizontal;
  FSorted := True;
end;

procedure TUnitIndexGrid.SetShowUnitLevel(Value: Boolean);
begin
  FShowUnitLevel := Value;
  Invalidate;
end;

function TUnitIndexGrid.GetUnitIndex(Index: Integer): Integer;
begin
  Result := FUnitIndexList[Index];
end;

procedure TUnitIndexGrid.SetUnitIndexList(Value: TUnitIndexList);
begin
  FUnitIndexList := Value;
  if Value <> nil then Count := Value.Count
  else Count := 0;
  Invalidate;
end;

procedure TUnitIndexGrid.SetUnitIndex(Index, Value: Integer);
begin
  FUnitIndexList[Index] := Value;
  Count := FUnitIndexList.Count;
end;

procedure TUnitIndexGrid.DrawCell(ACol, ARow: Longint; ARect: Windows.TRect; AState: Grids.TGridDrawState);
var
  Index, GFXIndex: Integer;
  Sequence: TImageSequence;
  Level: string;
begin
  Index := ImageIndex(ACol, ARow);
  if (FUnitIndexList <> nil) and (Index < FUnitIndexList.Count) and
    (FUnitIndexList[Index] <> -1) then
  begin
    if WorldSet^.FUnitResources.GetUnitResource(FUnitIndexList[Index]) <> nil then
    begin
      GFXIndex := WorldSet^.FUnitResources.GetUnitResource(FUnitIndexList[Index]).FUnitGFXResourceIndex;
      WorldSet^.FUnitGFXResources.GetUnitGFXResource(GFXIndex).AddRef;
      Sequence := WorldSet^.FUnitGFXResources.GetUnitGFXResource(GFXIndex).FSequences.GetImageSequence(2);
      if Sequence <> nil then
        BltImageSequence(Sequence, Canvas.Handle, 8, 16, ARect, 0, $610000);
      WorldSet^.FUnitGFXResources.GetUnitGFXResource(GFXIndex).Release;
      if FShowUnitLevel then
      begin
        Level := IntToStr(WorldSet^.FUnitResources.GetUnitResource(FUnitIndexList[Index]).FLevel);
        Canvas.Brush.Style := bsClear;
        Canvas.Font.Color := $FEDCCD;
        Inc(ARect.Left, 3);
        Inc(ARect.Top, 2);
        DrawText(Canvas.Handle, PChar(Level), Length(Level), ARect, $50);
        Dec(ARect.Left, 3);
        Dec(ARect.Top, 2);
      end;
    end
    else
    begin
      Canvas.Brush.Color := clRed;
      Canvas.FillRect(ARect);
    end;
  end
  else
  begin
    Canvas.Brush.Color := Color;
    Canvas.FillRect(ARect);
  end;
  inherited DrawCell(ACol, ARow, ARect, AState);
end;

procedure TUnitIndexGrid.AddUnit;
begin
  if (FSelectionControl <> nil) and (FUnitIndexList <> nil) and
    (FSelectionControl.FSelectedUnitIndex <> -1) then
    if FDoubleUnitsEnabled or
      (FUnitIndexList.IndexOf(FSelectionControl.FSelectedUnitIndex) = -1) then
    begin
      FUnitIndexList.Add(FSelectionControl.FSelectedUnitIndex);
      if FSorted then FUnitIndexList.SortUnits;
      Count := FUnitIndexList.Count;
      Invalidate;
    end;
end;

procedure TUnitIndexGrid.DeleteUnit;
var Index: Integer;
begin
  Index := ImageIndex(Col, Row);
  if (FUnitIndexList <> nil) and (Index < FUnitIndexList.Count) and (Index >= 0) then
  begin
    FUnitIndexList.Delete(Index);
    Count := FUnitIndexList.Count;
    Invalidate;
  end;
end;

function TUnitIndexGrid.GetUnit(ACol, ARow: Integer): Integer;
var Index: Integer;
begin
  Index := ImageIndex(ACol, ARow);
  { Original assumes a non-nil list here and in GetSelectedUnit. }
  if (Index >= 0) and (Index < FUnitIndexList.Count) then
    Result := FUnitIndexList[Index]
  else Result := -1;
end;

function TUnitIndexGrid.GetSelectedUnit: Integer;
var Index: Integer;
begin
  Index := ImageIndex(Col, Row);
  { Original also leaves negative indices unchecked here. }
  if Index < FUnitIndexList.Count then Result := FUnitIndexList[Index]
  else Result := -1;
end;

procedure TUnitIndexGrid.DblClick;
var Dlg: TUnitInfoDlg;
begin
  inherited DblClick;
  if GetSelectedUnit <> -1 then
  begin
    Dlg := TUnitInfoDlg.Create(Application);
    Dlg.ShowUnitResource(WorldSet^.FUnitResources.GetUnitResource(GetSelectedUnit));
    Dlg.Free;
  end;
end;

procedure Register;
begin
  RegisterComponents('AoWEngine', [TUnitIndexGrid]);
end;

initialization
finalization

end.
