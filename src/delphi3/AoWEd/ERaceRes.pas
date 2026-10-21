unit ERaceRes;

{ Race resource editor recovered from AoWEd.exe. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AlgnmBox, AoWREFrm, UnitIGrd, AoWE;

type
  TRaceResourceEditForm = class;
  TRaceResourceEditor = class;


  { TRaceResourceEditForm: size $278, inherited $1F8 resource. VMT 00411264. }
  TRaceResourceEditForm = class(TAoWResourceEditForm)
  public
    published
    PageControl1: TPageControl; { +01FC }
    GeneralSheet: TTabSheet; { +0200 }
    UnitSheet: TTabSheet; { +0204 }
    Label1: TLabel; { +0208 }
    Label2: TLabel; { +020C }
    Label3: TLabel; { +0210 }
    Label4: TLabel; { +0214 }
    Label6: TLabel; { +0218 }
    ILManagerComboBox: TILManagerComboBox; { +021C }
    AlignmentBox: TAlignmentBox; { +0220 }
    RaceNameAdjectiveEdit: TEdit; { +0224 }
    RaceNamePluralEdit: TEdit; { +0228 }
    RaceNameEdit: TEdit; { +022C }
    AddBtn: TButton; { +0230 }
    DeleteBtn: TButton; { +0234 }
    UnitIndexGrid: TUnitIndexGrid; { +0238 }
    CitySheet: TTabSheet; { +023C }
    GroupBox1: TGroupBox; { +0240 }
    DefaultUnitProdGrid: TUnitIndexGrid; { +0244 }
    Label5: TLabel; { +0248 }
    Label7: TLabel; { +024C }
    Label8: TLabel; { +0250 }
    Label9: TLabel; { +0254 }
    AddProdBtn: TButton; { +0258 }
    DeleteProdBtn: TButton; { +025C }
    RaceColorBtn: TButton; { +0260 }
    ColorBox: TShape; { +0264 }
    ColorDialog: TColorDialog; { +0268 }
    DescriptionSheet: TTabSheet; { +026C }
    Panel8: TPanel; { +0270 }
    DescriptionMemo: TMemo; { +0274 }
    public
    procedure FormCreate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure AddBtnClick(Sender: TObject);
    procedure DeleteBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure AddProdBtnClick(Sender: TObject);
    procedure DeleteProdBtnClick(Sender: TObject);
    procedure RaceColorBtnClick(Sender: TObject);
  end;

  { TRaceResourceEditor (instance size 8, VMT 0041167C) }
  TRaceResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

uses UnitFlt;

class function TRaceResourceEditor.EditorClassID: Integer;
begin
  Result := $20201;
end;

class procedure TRaceResourceEditor.Edit(Obj: TEObject; AEngine: TEngine; Done: TEditDoneEvent);
begin
  TRaceResourceEditForm.vmt80(AEngine, TEResource(Obj), Done);
end;

procedure TRaceResourceEditForm.FormCreate(Sender: TObject);
var Resource: TRaceResource;
begin
  Resource := TRaceResource(FEditResource);
  ColorBox.Brush.Color := Resource.FHeroUnitIndex;
  AlignmentBox.SetAlignments(Resource.FAlignments);
  RaceNameEdit.Text := Resource.FName;
  RaceNamePluralEdit.Text := Resource.FRaceName;
  RaceNameAdjectiveEdit.Text := Resource.FDescription;
  ILManagerComboBox.ILManager := AoWHSSet.ImageLibraryManager;
  ILManagerComboBox.ImageLibraryName := Resource.FImageLibraryName;
  UnitFloater.ResetSelection;
  with UnitFloater.UnitTabControl.FSelectionControl do
  begin
    FShowAllCategory := True;
    FShowRaceCategories := False;
    FShowTypeCategories := False;
  end;
  UnitFloater.UnitTabControl.UpdateSelection;
  UnitIndexGrid.FSelectionControl := UnitFloater.UnitTabControl.FSelectionControl;
  UnitIndexGrid.SetUnitIndexList(Resource.FUnitIndexes);
  DefaultUnitProdGrid.SetUnitIndexList(Resource.FSpecialUnitIndexes);
  DescriptionMemo.Text := Resource.FHeroNames.Text;
end;

procedure TRaceResourceEditForm.OKBtnClick(Sender: TObject);
var Resource: TRaceResource;
begin
  Resource := TRaceResource(FEditResource);
  Resource.FAlignments := AlignmentBox.FAlignments;
  Resource.FName := RaceNameEdit.Text;
  Resource.FRaceName := RaceNamePluralEdit.Text;
  Resource.FDescription := RaceNameAdjectiveEdit.Text;
  Resource.SetImageLibraryName(ILManagerComboBox.ImageLibraryName);
  Resource.FHeroUnitIndex := ColorBox.Brush.Color;
  Resource.FHeroNames.Text := DescriptionMemo.Text;
end;

procedure TRaceResourceEditForm.FormDestroy(Sender: TObject);
begin
  UnitFloater.Hide;
end;

procedure TRaceResourceEditForm.AddBtnClick(Sender: TObject);
begin
  UnitIndexGrid.AddUnit;
end;

procedure TRaceResourceEditForm.DeleteBtnClick(Sender: TObject);
begin
  UnitIndexGrid.DeleteUnit;
end;

procedure TRaceResourceEditForm.FormShow(Sender: TObject);
begin
  UnitFloater.Show;
end;

procedure TRaceResourceEditForm.AddProdBtnClick(Sender: TObject);
begin
  with DefaultUnitProdGrid do
  begin
    TRaceResource(FEditResource).FSpecialUnitIndexes[Col] := UnitFloater.UnitTabControl.FSelectionControl.FSelectedUnitIndex;
    Invalidate;
  end;
end;

procedure TRaceResourceEditForm.DeleteProdBtnClick(Sender: TObject);
begin
  with DefaultUnitProdGrid do
  begin
    TRaceResource(FEditResource).FSpecialUnitIndexes[Col] := -1;
    Invalidate;
  end;
end;

procedure TRaceResourceEditForm.RaceColorBtnClick(Sender: TObject);
begin
  ColorDialog.Color := ColorBox.Brush.Color;
  with ColorDialog do
  begin
    if Execute then ColorBox.Brush.Color := ColorDialog.Color;
  end;
end;

end.
