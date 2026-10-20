unit TerCBox;

{ The TerCBox unit of HSEPack.dpl: a combo box listing the terrain, decoration or overlay types of
  the hexagon set of a THexagonSpriteEngine (registered on the HS-Engine palette page). }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, Engine,
  HSEngine;

type
  TTerrainComboBoxMode = (tmTerrain, tmDecoration, tmOverlay);

  { TerCBox.TTerrainComboBox (instance size 380): +$170 FMode, +$171 FTerrainType (-1 transparent,
    -2 none), +$174 FHexagonSpriteEngine, +$178 FAllowTransparent }
  TTerrainComboBox = class(TComboBox)
  private
    FMode: TTerrainComboBoxMode;
    FTerrainType: ShortInt;
    FHexagonSpriteEngine: THexagonSpriteEngine;
    FAllowTransparent: Boolean;
    function GetSelectedTerrain: ShortInt;
    procedure SetTerrainType(Value: ShortInt);
    procedure SetHexagonSpriteEngine(Value: THexagonSpriteEngine);
  protected
    procedure Change; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure GenerateTerrainItems;
  published
    property Mode: TTerrainComboBoxMode read FMode write FMode;
    property TerrainType: ShortInt read FTerrainType write SetTerrainType;
    property HexagonSpriteEngine: THexagonSpriteEngine read FHexagonSpriteEngine write SetHexagonSpriteEngine;
    property AllowTransparent: Boolean read FAllowTransparent write FAllowTransparent;
  end;

procedure Register;

implementation

constructor TTerrainComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Style := csDropDownList;
  FTerrainType := -2;
  FAllowTransparent := True;
end;

function TTerrainComboBox.GetSelectedTerrain: ShortInt;
begin
  if (ItemIndex >= 0) and (FHexagonSpriteEngine <> nil) and
    (FHexagonSpriteEngine.HSEngine.HSSet <> nil) then
    Result := ShortInt(Items.Objects[ItemIndex])
  else
    Result := -2;
end;

procedure TTerrainComboBox.SetTerrainType(Value: ShortInt);
begin
  FTerrainType := Value;
  if (Parent <> nil) and (FHexagonSpriteEngine <> nil) and
    (FHexagonSpriteEngine.HSEngine.HSSet <> nil) then
    if Value >= 0 then
      ItemIndex := Items.IndexOfObject(TObject(Value))
    else
      ItemIndex := 0;
  FTerrainType := GetSelectedTerrain;
  Update;
end;

procedure TTerrainComboBox.GenerateTerrainItems;
var
  HSSet: THSSet;
  I: Integer;
begin
  if (FHexagonSpriteEngine <> nil) and
    (FHexagonSpriteEngine.HSEngine.HSSet <> nil) then
  begin
    Items.Clear;
    HSSet := FHexagonSpriteEngine.HSEngine.HSSet;
    if FMode = tmTerrain then
    begin
      if FAllowTransparent then Items.AddObject(TransparentStr, TObject(-1));
      for I := 0 to HSSet.TerrainTypes.Count - 1 do
      begin
        Items.AddObject(HSSet.TerrainTypes[I], TObject(I));
        if I = FTerrainType then ItemIndex := Items.Count - 1;
      end;
      if (ItemIndex = -1) and (HSSet.TerrainTypes.Count <> 0) then
      begin
        ItemIndex := 0;
        FTerrainType := GetSelectedTerrain;
      end;
    end
    else if FMode = tmDecoration then
    begin
      for I := 0 to HSSet.DecorationTypes.Count - 1 do
      begin
        Items.AddObject(HSSet.DecorationTypes[I], TObject(I));
        if I = FTerrainType then ItemIndex := Items.Count - 1;
      end;
      if (ItemIndex = -1) and (HSSet.DecorationTypes.Count <> 0) then
      begin
        ItemIndex := 0;
        FTerrainType := GetSelectedTerrain;
      end;
    end
    else
    begin
      if FAllowTransparent then Items.AddObject(TransparentStr, TObject(-1));
      for I := 0 to HSSet.OverlayTypes.Count - 1 do
      begin
        Items.AddObject(HSSet.OverlayTypes[I], TObject(I));
        if I = FTerrainType then ItemIndex := Items.Count - 1;
      end;
      if (ItemIndex = -1) and (HSSet.OverlayTypes.Count <> 0) then
      begin
        ItemIndex := 0;
        FTerrainType := GetSelectedTerrain;
      end;
    end;
  end;
end;

procedure TTerrainComboBox.SetHexagonSpriteEngine(Value: THexagonSpriteEngine);
begin
  FHexagonSpriteEngine := Value;
  if not (csDesigning in ComponentState) then GenerateTerrainItems;
end;

procedure TTerrainComboBox.Change;
begin
  FTerrainType := GetSelectedTerrain;
  inherited Change;
end;

procedure Register;
begin
  RegisterComponents('HS-Engine', [TTerrainComboBox]);
end;

end.
