unit EExplorS;

{ Draft declarations of EExplorS, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Defender controls at $210..$23C edit the inherited $20C map object. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, ExploreS, UnitFlt, EAoWMO, UnitGrid;

type
  TExplorationSiteEditForm = class;
  TExplorationSiteEditor = class;


  { TExplorationSiteEditForm (instance size 576, VMT 0041AB40) }
  TExplorationSiteEditForm = class(TAoWMapObjEditForm)
  public
    published
    DefendersSheet: TTabSheet; { +0210 }
    AutoGenerateBtn: TRadioButton; { +0214 }
    AutoGeneratePanel: TPanel; { +0218 }
    Label2: TLabel; { +021C }
    DefendersModeBox: TComboBox; { +0220 }
    UserDefinedPanel: TPanel; { +0224 }
    DefendersGrid: TUnitGrid; { +0228 }
    DeleteBtn: TButton; { +022C }
    AddBtn: TButton; { +0230 }
    UserDefinedBtn: TRadioButton; { +0234 }
    Panel3: TPanel; { +0238 }
    BorderPanel: TDrawPanel; { +023C }
    public
    procedure AddBtnClick(Sender: TObject);
    procedure DeleteBtnClick(Sender: TObject);
    procedure MainPageControlChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure UserDefinedBtnClick(Sender: TObject);
    procedure AutoGenerateBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DefendersModeBoxChange(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BorderPanelDraw(Sender: TObject; const R: TRect);
  end;

  { TExplorationSiteEditor (instance size 8, VMT 0041AE5C) }
  TExplorationSiteEditor = class(TAoWMapObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu); override;
  end;


implementation

class function TExplorationSiteEditor.EditorClassID: Integer;
begin Result := $203C1; end;

class procedure TExplorationSiteEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin TExplorationSiteEditForm.vmt90(Obj, Done); end;

class procedure TExplorationSiteEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu);
begin Handled := Handled + [emEdit]; end;

procedure TExplorationSiteEditForm.AddBtnClick(Sender: TObject);
begin
  DefendersGrid.AddUnit;
end;


procedure TExplorationSiteEditForm.DeleteBtnClick(Sender: TObject);
begin
  DefendersGrid.DeleteUnit;
end;


procedure TExplorationSiteEditForm.MainPageControlChange(Sender: TObject);
begin
  if MainPageControl.ActivePage = DefendersSheet then
    if UserDefinedBtn.Checked then UnitFloater.Show else UnitFloater.Hide;
end;


procedure TExplorationSiteEditForm.FormCreate(Sender: TObject);
begin
  MainPageControl.ActivePage := DefendersSheet;
  DefendersGrid.SetUnits(TExplorationSite(FMapObject).FDefenders);
  DefendersGrid.FSelectionControl := UnitFloater.UnitTabControl.FSelectionControl;
  UnitFloater.ResetSelection;
  UnitFloater.SetShowHeroes(True);
  UnitFloater.UnitTabControl.UpdateSelection;
  Caption := FMapObject.EditName;
end;


procedure TExplorationSiteEditForm.UserDefinedBtnClick(Sender: TObject);
begin
  DefendersGrid.SelectionEnabled := True;
  UserDefinedPanel.Enabled := True;
  AutoGeneratePanel.Enabled := False;
  TExplorationSite(FMapObject).FDefendersMode := dmUserDefined;
  UnitFloater.Show;
end;


procedure TExplorationSiteEditForm.AutoGenerateBtnClick(Sender: TObject);
begin
  DefendersGrid.SelectionEnabled := False;
  UserDefinedPanel.Enabled := False;
  AutoGeneratePanel.Enabled := True;
  TExplorationSite(FMapObject).FDefendersMode := TDefendersMode(DefendersModeBox.ItemIndex + 1);
  UnitFloater.Hide;
end;


procedure TExplorationSiteEditForm.FormDestroy(Sender: TObject);
begin
  UnitFloater.Hide;
end;


procedure TExplorationSiteEditForm.DefendersModeBoxChange(Sender: TObject);
begin
  TExplorationSite(FMapObject).FDefendersMode := TDefendersMode(DefendersModeBox.ItemIndex + 1);
end;


procedure TExplorationSiteEditForm.OKBtnClick(Sender: TObject);
begin
  if AutoGenerateBtn.Checked then TExplorationSite(FMapObject).FDefenders.Clear
  else TExplorationSite(FMapObject).FDefendersMode := dmUserDefined;
  TExplorationSite(FMapObject).Update;
  inherited OKBtnClick(Sender);
end;


procedure TExplorationSiteEditForm.FormShow(Sender: TObject);
begin
  inherited FormShow;
  if TExplorationSite(FMapObject).FDefendersMode = dmUserDefined then
  begin
    UserDefinedBtn.Checked := True;
    UserDefinedBtnClick(Self);
    DefendersModeBox.ItemIndex := 1;
  end
  else
  begin
    AutoGenerateBtn.Checked := True;
    DefendersModeBox.ItemIndex := Ord(TExplorationSite(FMapObject).FDefendersMode) - 1;
    AutoGenerateBtnClick(Self);
  end;
end;


procedure TExplorationSiteEditForm.BorderPanelDraw(Sender: TObject; const R: TRect);
var S: TStructure;
begin
  S := TStructure(FMapObject);
  if S <> nil then S.ShowBorderImageDC(BorderPanel.Canvas.Handle, R);
end;



end.
