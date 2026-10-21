unit Ecity;

{ Draft declarations of Ecity, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  City controls at $230..$25C edit the inherited $20C map object. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, City, EConstr, UnitFlt, SpinEdit;

type
  TCityEditForm = class;
  TCityEditor = class;


  { TCityEditForm (instance size 608, VMT 00418B78) }
  TCityEditForm = class(TPlayerConstructionEditForm)
  public
    published
    Label2: TLabel; { +0230 }
    NameEdit: TEdit; { +0234 }
    Label6: TLabel; { +0238 }
    Label3: TLabel; { +023C }
    Label4: TLabel; { +0240 }
    WallComboBox: TComboBox; { +0244 }
    LevelEdit: TSpin; { +0248 }
    IncomeLabel: TPanel; { +024C }
    Label5: TLabel; { +0250 }
    DefendersCB: TComboBox; { +0254 }
    Label9: TLabel; { +0258 }
    RaceCB: TComboBox; { +025C }
    public
    procedure UpdateControls;
    procedure FormCreate(Sender: TObject);
    procedure RaceCBChange(Sender: TObject);
    procedure RazedBoxClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PlayerComboBoxChange;
    procedure DefendersCBChange(Sender: TObject);
  end;

  { TCityEditor (instance size 8, VMT 00418DE0) }
  TCityEditor = class(TAoWMapObjectEditor)
  public
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu); override;
  end;


implementation

procedure TCityEditForm.UpdateControls;
var
  C: TCity;
  I: Integer;
begin
  C := TCity(FMapObject);
  NameEdit.Text := C.GetName;
  PlayerComboBox.SetPlayerIndex(C.FPlayer);
  if AoWHSMap.FGameType = gtCampaign then
  begin
    RaceCB.Items.AddObject('Ally 1', TObject(-3));
    RaceCB.Items.AddObject('Ally 2', TObject(-4));
    RaceCB.Items.AddObject('Ally 3', TObject(-5));
  end;
  RaceCB.Items.AddObject('Random', TObject(-1));
  for I := 0 to AoWHSMap.FRaces.GetCount - 1 do
    if (AoWHSMap.FRaces.GetRace(I) <> nil) and AoWHSMap.FRaces.GetRace(I).FEnabled then
      RaceCB.Items.AddObject(TranslateRStr(RaceNamesPluralRStr[I]), TObject(I));
  RaceCB.ItemIndex := RaceCB.Items.IndexOfObject(TObject(C.FRace));
  WallComboBox.ItemIndex := C.FWallType;
  LevelEdit.Value := C.FUpgradeLevel;
  LevelEdit.MaxValue := C.GetSize;
  IncomeLabel.Caption := IntToStr(C.FIncome);
  if (C.FPlayer <= 0) or
     ((AoWHSMap.FPlayers.GetPlayers(C.FPlayer).FPlayerType <> ptHuman) and
       AoWHSMap.FPlayers.GetPlayers(C.FPlayer).FParticipating) then
  begin
    DefendersCB.Color := clWindow;
    DefendersCB.Enabled := True;
  end
  else
  begin
    DefendersCB.Color := clBtnFace;
    DefendersCB.Enabled := False;
  end;
  DefendersCB.ItemIndex := Ord(C.FDefendersMode);
  MainPageControl.ActivePage := MainPageControl.Pages[0];
end;


class procedure TCityEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

class procedure TCityEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu);
begin end;

procedure TCityEditForm.FormCreate(Sender: TObject);
begin
  inherited FormCreate(Sender);
  UpdateControls;
end;


procedure TCityEditForm.RaceCBChange(Sender: TObject);
begin
  with RaceCB do TCity(FMapObject).SetRace(Integer(Items.Objects[ItemIndex]));
  BorderPanel.Refresh;
end;


procedure TCityEditForm.RazedBoxClick(Sender: TObject);
begin
  inherited RazedBoxClick(Sender);
  if RazedBox.Checked then
  begin
    WallComboBox.Color := clBtnFace;
    WallComboBox.Enabled := False;
    LevelEdit.Color := clBtnFace;
    LevelEdit.Enabled := False;
  end
  else
  begin
    WallComboBox.Color := clWindow;
    WallComboBox.Enabled := True;
    LevelEdit.Color := clWindow;
    LevelEdit.Enabled := True;
  end;
  TCity(FMapObject).SetRazed(RazedBox.Checked);
  BorderPanel.Refresh;
end;


procedure TCityEditForm.OKBtnClick(Sender: TObject);
var C: TCity;
begin
  C := TCity(FMapObject);
  C.SetName(NameEdit.Text);
  C.SetUpgradeLevel(LevelEdit.Value);
  with RaceCB do C.SetRace(Integer(Items.Objects[ItemIndex]));
  C.SetWallType(Byte(WallComboBox.ItemIndex));
  inherited OKBtnClick(Sender);
end;


procedure TCityEditForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  UnitFloater.Hide;
  inherited FormClose(Sender, Action);
end;


procedure TCityEditForm.PlayerComboBoxChange;
begin
  TPlayerStructure(FMapObject).SetPlayer(PlayerComboBox.FPlayerIndex);
end;


procedure TCityEditForm.DefendersCBChange(Sender: TObject);
begin
  TCity(FMapObject).FDefendersMode := TDefendersGenerateMode(DefendersCB.ItemIndex);
end;



end.
