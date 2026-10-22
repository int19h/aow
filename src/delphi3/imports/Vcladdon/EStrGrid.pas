unit EStrGrid;

{ Link-only edit grid layout (516 bytes). }
interface
uses Grids;
type
  TEditStringGrid = class(TStringGrid)
  private
    FExternal: array[0..15] of Byte;
  public
    procedure SetRowCount(Value: Integer);
  end;
implementation
procedure TEditStringGrid.SetRowCount(Value: Integer); begin end;
initialization
finalization
end.
