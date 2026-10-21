unit EWizardsTower;

{ Draft declarations of EWizardsTower, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EAoWMO;

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
    procedure FormCreate;  { draft }
    procedure OKBtnClick(A1: Integer; A2: Integer);  { draft }
    procedure CustomRBClick;  { draft }
    procedure BorderPanelDraw(A1: Integer; A2: Integer);  { draft }
  end;

  { TWizardsTowerEditor (instance size 8, VMT 0041C67C) }
  TWizardsTowerEditor = class(TAoWMapObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu); override;
  end;


implementation

class function TWizardsTowerEditor.EditorClassID: Integer;
begin Result := 0; end;

class procedure TWizardsTowerEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

class procedure TWizardsTowerEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu);
begin end;

procedure TWizardsTowerEditForm.FormCreate;
begin end;

procedure TWizardsTowerEditForm.OKBtnClick(A1: Integer; A2: Integer);
begin end;

procedure TWizardsTowerEditForm.CustomRBClick;
begin end;

procedure TWizardsTowerEditForm.BorderPanelDraw(A1: Integer; A2: Integer);
begin end;


end.
