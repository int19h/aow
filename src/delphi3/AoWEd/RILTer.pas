unit RILTer;

{ Draft declarations of RILTer, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  The $308 inherited resource supplies terrain and overlay markers. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, RMultiHx;

type
  TILTerrainResourceEditForm = class;
  TILTerrainResourceEditor = class;


  { TILTerrainResourceEditForm (instance size 828, VMT 00406D84) }
  TILTerrainResourceEditForm = class(TMultiHexResourceEditForm)
  public
    procedure vmt84; override;
    constructor CreateForm(AEngine: THSEngine; Resource: TMapObjectResource; Done: TEditDoneEvent); override;
    procedure vmt98(const SD: TSurfaceDesc); override;
    function vmt9C(A1: Integer): Boolean; override;
  end;

  { TILTerrainResourceEditor (instance size 8, VMT 00406EB4) }
  TILTerrainResourceEditor = class(TEObjectEditor)
  public
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

class procedure TILTerrainResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

constructor TILTerrainResourceEditForm.CreateForm(AEngine: THSEngine; Resource: TMapObjectResource; Done: TEditDoneEvent);
begin
  inherited CreateForm(AEngine, Resource, Done);
  TerrainComboBox.Items.Clear;
  TerrainComboBox.Items.AddObject('Transparent', TObject(0));
  TerrainComboBox.Items.AddObject('Used', TObject(1));
  TerrainComboBox.ItemIndex := 1;
end;


procedure TILTerrainResourceEditForm.vmt84;
begin
  inherited vmt84;
end;


procedure TILTerrainResourceEditForm.vmt98(const SD: TSurfaceDesc);
var
  I: Integer;
  Overlay: Shortint;
  Text: string;
begin
  for I := TMultiHexMOR(FResource).TerrainList.Count - 1 downto 0 do
    if TMultiHexMOR(FResource).TerrainList.Terrain[I] >= -1 then
    begin
      if TMultiHexMOR(FResource).TerrainList.Terrain[I] >= 0 then
        ShowHexagonText(I, 0, -3, 'Used', 1, SD);
      Overlay := TMultiHexMOR(FResource).TerrainList.Overlay[I];
      if Overlay >= 0 then
      begin
        Text := FEngine.HSSet.OverlayTypes[Overlay];
        ShowHexagonText(I, 0, 5, Text, 1, SD);
      end;
    end;
end;


function TILTerrainResourceEditForm.vmt9C(A1: Integer): Boolean;
var R: TMultiHexMOR;
begin
  R := TMultiHexMOR(FResource);
  if (R.TerrainList.Terrain[A1] = -2) or
     (R.TerrainList.Terrain[A1] <> TerrainComboBox.ItemIndex - 1) or
     (R.TerrainList.Overlay[A1] <> OverlayComboBox.TerrainType) then
  begin
    R.TerrainList.Terrain[A1] := TerrainComboBox.ItemIndex - 1;
    R.TerrainList.Overlay[A1] := OverlayComboBox.TerrainType;
  end
  else
  begin
    R.TerrainList.Terrain[A1] := -2;
    R.TerrainList.Overlay[A1] := -2;
  end;
  Result := True;
end;



end.
