unit EAUnitRes;

{ Draft declarations of EAUnitRes, from AoWEd.exe.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  $214 FUnitResource is the selected abstract unit resource. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWREFrm;

type
  TAbstractUnitResourceEditForm = class;


  { TAbstractUnitResourceEditForm (instance size 536, VMT 0040FCC4; $214 FUnitResource) }
  TAbstractUnitResourceEditForm = class(TAoWResourceEditForm)
  public
    published
    MainPageControl: TPageControl; { +01FC }
    GFXSFXSheet: TTabSheet; { +0200 }
    GFXGroupBox: TGroupBox; { +0204 }
    Label1: TLabel; { +0208 }
    UnitGFXBox: TComboBox; { +020C }
    PreviewImagePanel: TDrawPanel; { +0210 }
    public
    FUnitResource: TAbstractUnitResource; { $214 }
    published procedure FormCreate; public
    published procedure UnitGFXBoxChange(Sender: TObject); public
    published procedure PreviewImagePanelDraw(Sender: TObject; const R: TRect); public
  end;


implementation

procedure TAbstractUnitResourceEditForm.FormCreate;
begin
  FUnitResource := TAbstractUnitResource(FEditResource);
  AoWHSSet.FUnitGFXResources.CreateUnitGFXSelectionList(UnitGFXBox.Items);
  UnitGFXBox.ItemIndex := UnitGFXBox.Items.IndexOfObject(TObject(FUnitResource.FUnitGFXResourceIndex));
  if UnitGFXBox.ItemIndex = -1 then UnitGFXBox.ItemIndex := 0;
  UnitGFXBoxChange(Self);
end;

procedure TAbstractUnitResourceEditForm.UnitGFXBoxChange(Sender: TObject);
begin
  with UnitGFXBox do
    if ItemIndex <> -1 then
      FUnitResource.SetUnitGFXResourceIndex(Integer(Items.Objects[ItemIndex]))
    else FUnitResource.SetUnitGFXResourceIndex(-1);
  PreviewImagePanel.Invalidate;
end;

procedure TAbstractUnitResourceEditForm.PreviewImagePanelDraw(Sender: TObject; const R: TRect);
var
  Image: TLibraryImage;
  DrawRect: TRect;
begin
  Image := FUnitResource.GetCellImage;
  if Image <> nil then
    BltLibraryImage(PreviewImagePanel.Canvas, Image, R, bmCenter, 100, 100,
      0, Color, False, DrawRect);
end;


end.
