unit EGems;

{ Draft declarations of EGems, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EAoWMO, SpinEdit;

type
  TGemsEditForm = class;
  TGemsEditor = class;


  { TGemsEditForm (instance size 560, VMT 0041A658) }
  TGemsEditForm = class(TAoWMapObjEditForm)
  public
    published
    UserDefined: TRadioButton; { +0210 }
    AutoGenerate: TRadioButton; { +0214 }
    AutoGeneratePanel: TPanel; { +0218 }
    Label2: TLabel; { +021C }
    GenerateModeBox: TComboBox; { +0220 }
    UserDefinedPanel: TPanel; { +0224 }
    Label1: TLabel; { +0228 }
    GemsSpin: TSpin; { +022C }
    public
    procedure GemsSpinChange;  { draft }
    procedure FormCreate;  { draft }
    procedure OKBtnClick;  { draft }
    procedure AutoGenerateClick;  { draft }
    procedure UserDefinedClick;  { draft }
    procedure GenerateModeBoxChange;  { draft }
  end;

  { TGemsEditor (instance size 8, VMT 0041A898) }
  TGemsEditor = class(TAoWMapObjectEditor)
  public
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu); override;
  end;


implementation

class procedure TGemsEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

class procedure TGemsEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu);
begin end;

procedure TGemsEditForm.GemsSpinChange;
begin end;

procedure TGemsEditForm.FormCreate;
begin end;

procedure TGemsEditForm.OKBtnClick;
begin end;

procedure TGemsEditForm.AutoGenerateClick;
begin end;

procedure TGemsEditForm.UserDefinedClick;
begin end;

procedure TGemsEditForm.GenerateModeBoxChange;
begin end;


end.
