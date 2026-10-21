unit EWizardsTower;

{ Draft declarations of EWizardsTower, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EAoWMO, WizardsTower;

type
  TWizardsTowerEditForm = class;
  TWizardsTowerEditor = class;


  { TWizardsTowerEditForm (instance size 592, VMT 0041C3F8) }
  TWizardsTowerEditForm = class(TAoWMapObjEditForm)
  public
    published
    CustomRB: TRadioButton; { +0210 }
    RandomRB: TRadioButton; { +0214 }
    SpellComboBox: TComboBox; { +0218 }
    SpellLbl: TLabel; { +021C }
    SpheresGB: TGroupBox; { +0220 }
    LifeCB: TCheckBox; { +0224 }
    WaterCB: TCheckBox; { +0228 }
    EarthCB: TCheckBox; { +022C }
    SecretCB: TCheckBox; { +0230 }
    AirCB: TCheckBox; { +0234 }
    FireCB: TCheckBox; { +0238 }
    DeathCB: TCheckBox; { +023C }
    CosmicCB: TCheckBox; { +0240 }
    LevelRG: TRadioGroup; { +0244 }
    Panel4: TPanel; { +0248 }
    BorderPanel: TDrawPanel; { +024C }
    public
    procedure UpdateControls;
    procedure FormCreate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure CustomRBClick(Sender: TObject);
    procedure BorderPanelDraw(Sender: TObject; const Rect: TRect);
  end;

  { TWizardsTowerEditor (instance size 8, VMT 0041C67C) }
  TWizardsTowerEditor = class(TAoWMapObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu); override;
  end;


implementation

procedure TWizardsTowerEditForm.UpdateControls;
begin
  LifeCB.Enabled := RandomRB.Checked;
  DeathCB.Enabled := RandomRB.Checked;
  WaterCB.Enabled := RandomRB.Checked;
  FireCB.Enabled := RandomRB.Checked;
  EarthCB.Enabled := RandomRB.Checked;
  AirCB.Enabled := RandomRB.Checked;
  CosmicCB.Enabled := RandomRB.Checked;
  SecretCB.Enabled := RandomRB.Checked;
  LevelRG.Enabled := RandomRB.Checked;
  SpellComboBox.Enabled := not RandomRB.Checked;
end;

class function TWizardsTowerEditor.EditorClassID: Integer;
begin Result := $2089E; end;

class procedure TWizardsTowerEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin TWizardsTowerEditForm.vmt90(Obj, Done); end;

class procedure TWizardsTowerEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu);
begin Handled := Handled + [emEdit]; end;

procedure TWizardsTowerEditForm.FormCreate(Sender: TObject);
var
  Tower: TWizardsTower;
  List: TStringList;
  I: Integer;
begin
  Tower := TWizardsTower(FMapObject);
  CustomRB.Checked := not Tower.FGenerateSpell;
  RandomRB.Checked := Tower.FGenerateSpell;
  LevelRG.ItemIndex := Tower.FSpellLevel - 1;
  LifeCB.Checked := msLife in Tower.FMagicSpheres;
  DeathCB.Checked := msDeath in Tower.FMagicSpheres;
  WaterCB.Checked := msWater in Tower.FMagicSpheres;
  FireCB.Checked := msFire in Tower.FMagicSpheres;
  EarthCB.Checked := msEarth in Tower.FMagicSpheres;
  AirCB.Checked := msAir in Tower.FMagicSpheres;
  CosmicCB.Checked := msCosmos in Tower.FMagicSpheres;
  SecretCB.Checked := msSecret in Tower.FMagicSpheres;
  List := TStringList.Create;
  for I := 0 to AoWHSSet.FSpellControl.GetCount - 1 do
    if AoWHSSet.FSpellControl.GetSpell(I) <> nil then
      List.AddObject(AoWHSSet.FSpellControl.GetSpell(I).FSpellName, AoWHSSet.FSpellControl.GetSpell(I));
  List.Sort;
  SpellComboBox.Items.Assign(List);
  List.Free;
  SpellComboBox.ItemIndex := SpellComboBox.Items.IndexOfObject(AoWHSSet.FSpellControl.GetSpell(Tower.FSpellID));
end;

procedure TWizardsTowerEditForm.OKBtnClick(Sender: TObject);
var
  Tower: TWizardsTower;
begin
  Tower := TWizardsTower(FMapObject);
  Tower.FSpellLevel := LevelRG.ItemIndex + 1;
  LevelRG.ItemIndex := Tower.FSpellLevel - 1;
  Tower.FMagicSpheres := [];
  Tower.FGenerateSpell := RandomRB.Checked;
  if LifeCB.Checked then Tower.FMagicSpheres := Tower.FMagicSpheres + [msLife];
  if DeathCB.Checked then Tower.FMagicSpheres := Tower.FMagicSpheres + [msDeath];
  if WaterCB.Checked then Tower.FMagicSpheres := Tower.FMagicSpheres + [msWater];
  if FireCB.Checked then Tower.FMagicSpheres := Tower.FMagicSpheres + [msFire];
  if EarthCB.Checked then Tower.FMagicSpheres := Tower.FMagicSpheres + [msEarth];
  if AirCB.Checked then Tower.FMagicSpheres := Tower.FMagicSpheres + [msAir];
  if CosmicCB.Checked then Tower.FMagicSpheres := Tower.FMagicSpheres + [msCosmos];
  if SecretCB.Checked then Tower.FMagicSpheres := Tower.FMagicSpheres + [msSecret];
  if SpellComboBox.ItemIndex <> -1 then
    with SpellComboBox do Tower.FSpellID := TSpell(Items.Objects[ItemIndex]).FSpellID
  else Tower.FSpellID := 0;
  UpdateControls;
  inherited OKBtnClick(Sender);
end;

procedure TWizardsTowerEditForm.CustomRBClick(Sender: TObject);
begin
  UpdateControls;
end;

procedure TWizardsTowerEditForm.BorderPanelDraw(Sender: TObject; const Rect: TRect);
var
  Tower: TWizardsTower;
begin
  Tower := TWizardsTower(FMapObject);
  if Tower <> nil then Tower.ShowBorderImageDC(BorderPanel.Canvas.Handle, Rect);
end;


end.
