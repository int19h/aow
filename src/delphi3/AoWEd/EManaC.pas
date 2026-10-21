unit EManaC;

{ Draft declarations of EManaC, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EAoWMO, SpinEdit;

type
  TManaCrystalsEditForm = class;
  TManaCrystalsEditor = class;


  { TManaCrystalsEditForm (instance size 560, VMT 0041BEF8) }
  TManaCrystalsEditForm = class(TAoWMapObjEditForm)
  public
    published
    AutoGenerate: TRadioButton; { +0210 }
    AutoGeneratePanel: TPanel; { +0214 }
    Label2: TLabel; { +0218 }
    GenerateModeBox: TComboBox; { +021C }
    UserDefinedPanel: TPanel; { +0220 }
    Label1: TLabel; { +0224 }
    ManaSpin: TSpin; { +0228 }
    UserDefined: TRadioButton; { +022C }
    public
    procedure ManaSpinChange;  { draft }
    procedure OKBtnClick;  { draft }
    procedure AutoGenerateClick;  { draft }
    procedure UserDefinedClick;  { draft }
    procedure GenerateModeBoxChange;  { draft }
  end;

  { TManaCrystalsEditor (instance size 8, VMT 0041C148) }
  TManaCrystalsEditor = class(TAoWMapObjectEditor)
  public
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu); override;
  end;


implementation

class procedure TManaCrystalsEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

class procedure TManaCrystalsEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu);
begin end;

procedure TManaCrystalsEditForm.ManaSpinChange;
begin end;

procedure TManaCrystalsEditForm.OKBtnClick;
begin end;

procedure TManaCrystalsEditForm.AutoGenerateClick;
begin end;

procedure TManaCrystalsEditForm.UserDefinedClick;
begin end;

procedure TManaCrystalsEditForm.GenerateModeBoxChange;
begin end;


end.
