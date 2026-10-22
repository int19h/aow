unit EDungeon;

{ Draft declarations of EDungeon, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Prisoner controls bind TDungeon at inherited $20C FMapObject. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EExplorS, UnitGrid;

type
  TDungeonEditForm = class;
  TDungeonEditor = class;


  { TDungeonEditForm (instance size 616, VMT 0041B27C) }
  TDungeonEditForm = class(TExplorationSiteEditForm)
  public
    published
    PrisonersSheet: TTabSheet; { +0240 }
    AutoGeneratePrisBtn: TRadioButton; { +0244 }
    AutoGeneratePrisPanel: TPanel; { +0248 }
    Label1: TLabel; { +024C }
    PrisonersModeBox: TComboBox; { +0250 }
    UserDefinedPrisPanel: TPanel; { +0254 }
    PrisonersGrid: TUnitGrid; { +0258 }
    DeletePrisBtn: TButton; { +025C }
    AddPrisBtn: TButton; { +0260 }
    UserDefinedPrisBtn: TRadioButton; { +0264 }
    public
    published procedure MainPageControlChange(Sender: TObject); public
    published procedure OKBtnClick(Sender: TObject); public
    published procedure PrisonersModeBoxChange(Sender: TObject); public
    published procedure AutoGeneratePrisBtnClick(Sender: TObject); public
    published procedure UserDefinedPrisBtnClick(Sender: TObject); public
    published procedure AddPrisBtnClick(Sender: TObject); public
    published procedure DeletePrisBtnClick(Sender: TObject); public
    published procedure FormCreate(Sender: TObject); public
    published procedure FormShow(Sender: TObject); public
  end;

  { TDungeonEditor (instance size 8, VMT 0041B568) }
  TDungeonEditor = class(TAoWMapObjectEditor)
  public class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu); override;
  end;


implementation

uses Dungeon, UnitFlt;

class procedure TDungeonEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin TDungeonEditForm.vmt90(Obj, Done); end;

class procedure TDungeonEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu);
begin Handled := Handled + [emEdit]; end;

procedure TDungeonEditForm.MainPageControlChange(Sender: TObject);
begin
  inherited MainPageControlChange(Sender);
  if MainPageControl.ActivePage = PrisonersSheet then
    if UserDefinedPrisBtn.Checked then UnitFloater.Show else UnitFloater.Hide;
end;

procedure TDungeonEditForm.OKBtnClick(Sender: TObject);
begin
  if AutoGeneratePrisBtn.Checked then TDungeon(FMapObject).FPrisoners.Clear
  else TDungeon(FMapObject).FPrisonersMode := pmUserDefined;
  inherited OKBtnClick(Sender);
end;

procedure TDungeonEditForm.PrisonersModeBoxChange(Sender: TObject);
begin
  TDungeon(FMapObject).FPrisonersMode := TPrisonersMode(PrisonersModeBox.ItemIndex + 1);
end;

procedure TDungeonEditForm.AutoGeneratePrisBtnClick(Sender: TObject);
begin
  UserDefinedPrisPanel.Enabled := False;
  AutoGeneratePrisPanel.Enabled := True;
  TDungeon(FMapObject).FPrisonersMode := TPrisonersMode(PrisonersModeBox.ItemIndex + 1);
  UnitFloater.Hide;
end;

procedure TDungeonEditForm.UserDefinedPrisBtnClick(Sender: TObject);
begin
  UserDefinedPrisPanel.Enabled := True;
  AutoGeneratePrisPanel.Enabled := False;
  TDungeon(FMapObject).FPrisonersMode := pmUserDefined;
  UnitFloater.Show;
end;

procedure TDungeonEditForm.AddPrisBtnClick(Sender: TObject);
begin
  PrisonersGrid.AddUnit;
end;

procedure TDungeonEditForm.DeletePrisBtnClick(Sender: TObject);
begin
  PrisonersGrid.DeleteUnit;
end;

procedure TDungeonEditForm.FormCreate(Sender: TObject);
begin
  inherited FormCreate(Sender);
  PrisonersGrid.SetUnits(TDungeon(FMapObject).FPrisoners);
  PrisonersGrid.FSelectionControl := UnitFloater.UnitTabControl.FSelectionControl;
end;

procedure TDungeonEditForm.FormShow(Sender: TObject);
begin
  inherited FormShow(Sender);
  if TDungeon(FMapObject).FPrisonersMode = pmUserDefined then
  begin
    UserDefinedPrisBtnClick(Self);
    PrisonersModeBox.ItemIndex := 1;
    UserDefinedPrisBtn.Checked := True;
  end
  else
  begin
    PrisonersModeBox.ItemIndex := Ord(TDungeon(FMapObject).FPrisonersMode) - 1;
    AutoGeneratePrisBtnClick(Self);
    AutoGeneratePrisBtn.Checked := True;
  end;
end;

class function TDungeonEditor.EditorClassID: Integer;
begin Result := $2032A; end;

end.
