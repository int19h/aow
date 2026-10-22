unit RConstr;

{ Construction resource editor recovered from AoWEd.exe. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, Buttons, RMultiHx, SpinEdit, UnitIGrd, AoWE;

type
  TConstructionResourceEditForm = class;
  TConstructionResourceEditor = class;


  { TConstructionResourceEditForm: size $378, inherited $308 resource. VMT 00408A78. }
  TConstructionResourceEditForm = class(TMultiHexResourceEditForm)
  public
    published
    TabSheet1: TTabSheet; { +033C }
    SelectSampleBox: TGroupBox; { +0340 }
    SFXManagerBox: TSFXManagerComboBox; { +0344 }
    LoopBox: TCheckBox; { +0348 }
    PlaySample: TSpeedButton; { +034C }
    Label10: TLabel; { +0350 }
    DescriptionSheet: TTabSheet; { +0354 }
    DescriptionMemo: TMemo; { +0358 }
    CombatTerrainTagPanel: TPanel; { +035C }
    CTTLabel: TLabel; { +0360 }
    CombatTerrainTagEdit: TSpin; { +0364 }
    RazeDefendersSheet: TTabSheet; { +0368 }
    RazeDefendersGrid: TUnitIndexGrid; { +036C }
    AddRazeDefender: TButton; { +0370 }
    DeleteRazeDefender: TButton; { +0374 }
    public
    constructor CreateForm(AEngine: THSEngine; Resource: TMapObjectResource; Done: TEditDoneEvent); override;
    procedure vmt98(const SD: TSurfaceDesc); override;
    function vmt9C(Hexagon: Integer): Boolean; override;
    published procedure LoopBoxClick(Sender: TObject); public
    published procedure PlaySampleClick(Sender: TObject); public
    published procedure SFXManagerBoxChange(Sender: TObject); public
    published procedure CloseBtnClick(Sender: TObject); public
    published procedure CombatTerrainTagEditChange(Sender: TObject); public
    published procedure AddRazeDefenderClick(Sender: TObject); public
    published procedure DeleteRazeDefenderClick(Sender: TObject); public
    published procedure MainPageControlChange(Sender: TObject); public
    published procedure FormHide(Sender: TObject); public
  end;

  { TConstructionResourceEditor (instance size 8, VMT 00408DFC) }
  TConstructionResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

uses UnitFlt;

class function TConstructionResourceEditor.EditorClassID: Integer;
begin
  Result := $2034B;
end;

class procedure TConstructionResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin
  TConstructionResourceEditForm.CreateForm(THSEngine(AEngine), TMapObjectResource(Obj), Done);
end;

constructor TConstructionResourceEditForm.CreateForm(AEngine: THSEngine; Resource: TMapObjectResource; Done: TEditDoneEvent);
begin
  inherited CreateForm(AEngine, Resource, Done);
  TerrainComboBox.Items.Clear;
  TerrainComboBox.Items.AddObject('Transparent', TObject(0));
  TerrainComboBox.Items.AddObject('Used', TObject(1));
  TerrainComboBox.ItemIndex := 1;
  SFXManagerBox.SFXManager := AoWEngine.HSSet.SFXManager;
  SFXManagerBox.SFXName := TStructureResource(FResource).FSelectSFX;
  LoopBox.Checked := TStructureResource(FResource).FSelectSFXLooped;
  DescriptionMemo.Text := TStructureResource(FResource).FDescription.Text;
  CombatTerrainTagEdit.Value := TStructureResource(FResource).FScannerIcon;
  RazeDefendersSheet.TabVisible := TStructureResource(FResource).FRazeable;
  RazeDefendersGrid.SetUnitIndexList(TStructureResource(FResource).FDefenders.FUnits);
end;

procedure TConstructionResourceEditForm.vmt98(const SD: TSurfaceDesc);
var I: Integer; OverlayType: Shortint; Text: string;
begin
  for I := FResource.TerrainList.Count - 1 downto 0 do
    if FResource.TerrainList.Terrain[I] >= -1 then
    begin
      if FResource.TerrainList.Terrain[I] >= 0 then
        ShowHexagonText(I, 0, -3, 'Used', 1, SD);
      OverlayType := FResource.TerrainList.Overlay[I];
      if OverlayType >= 0 then
        begin Text := FEngine.HSSet.OverlayTypes[OverlayType]; ShowHexagonText(I, 0, 5, Text, 1, SD); end;
    end;
end;

function TConstructionResourceEditForm.vmt9C(Hexagon: Integer): Boolean;
var Resource: TMultiHexMOR;
begin
  Resource := TMultiHexMOR(FResource);
  if (Resource.TerrainList.Terrain[Hexagon] = -2) or
    (Resource.TerrainList.Terrain[Hexagon] <> TerrainComboBox.ItemIndex - 1) or
    (Resource.TerrainList.Overlay[Hexagon] <> OverlayComboBox.TerrainType) then
  begin
    Resource.TerrainList.Terrain[Hexagon] := TerrainComboBox.ItemIndex - 1;
    Resource.TerrainList.Overlay[Hexagon] := OverlayComboBox.TerrainType;
  end
  else
  begin
    Resource.TerrainList.Terrain[Hexagon] := -2;
    Resource.TerrainList.Overlay[Hexagon] := -2;
  end;
  Result := True;
end;

procedure TConstructionResourceEditForm.LoopBoxClick(Sender: TObject);
begin
  TStructureResource(FResource).FSelectSFXLooped := LoopBox.Checked;
end;

procedure TConstructionResourceEditForm.PlaySampleClick(Sender: TObject);
begin
  if SFXManagerBox.SFXName <> '' then Sound.PlaySample(SFXManagerBox.SFXName);
end;

procedure TConstructionResourceEditForm.SFXManagerBoxChange(Sender: TObject);
begin
  TStructureResource(FResource).FSelectSFX := SFXManagerBox.SFXName;
end;

procedure TConstructionResourceEditForm.CloseBtnClick(Sender: TObject);
begin
  TStructureResource(FResource).FDescription.Text := DescriptionMemo.Text;
  inherited CloseBtnClick(Sender);
end;

procedure TConstructionResourceEditForm.CombatTerrainTagEditChange(Sender: TObject);
begin
  TStructureResource(FResource).FScannerIcon := CombatTerrainTagEdit.Value;
end;

procedure TConstructionResourceEditForm.AddRazeDefenderClick(Sender: TObject);
var Index: Integer;
begin
  Index := UnitFloater.UnitTabControl.FSelectionControl.FSelectedUnitIndex;
  if Index <> -1 then
  begin
    TStructureResource(FResource).FDefenders.AddUnit(RazeDefendersGrid.Row, Index);
    RazeDefendersGrid.Invalidate;
  end
  else MessageBeep(0);
end;

procedure TConstructionResourceEditForm.DeleteRazeDefenderClick(Sender: TObject);
begin
  TStructureResource(FResource).FDefenders.DeleteUnit(RazeDefendersGrid.Row, RazeDefendersGrid.Col);
  RazeDefendersGrid.Invalidate;
end;

procedure TConstructionResourceEditForm.MainPageControlChange(Sender: TObject);
begin
  inherited MainPageControlChange(Sender);
  if MainPageControl.ActivePage = RazeDefendersSheet then
  begin
    UnitFloater.ResetSelection;
    with UnitFloater.UnitTabControl.FSelectionControl do
    begin
      FShowAllCategory := True;
      FShowRaceCategories := True;
      FShowTypeCategories := True;
      FMinimumLevel := 1;
      FMaximumLevel := 4;
    end;
    UnitFloater.UnitTabControl.UpdateSelection;
    UnitFloater.Show;
  end
  else UnitFloater.Hide;
end;

procedure TConstructionResourceEditForm.FormHide(Sender: TObject);
begin
  UnitFloater.Hide;
end;

end.
