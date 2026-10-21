unit Ecity;

{ Draft declarations of Ecity, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EConstr, SpinEdit;

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
    procedure FormCreate;  { draft }
    procedure RaceCBChange;  { draft }
    procedure RazedBoxClick;  { draft }
    procedure OKBtnClick(A1: Integer);  { draft }
    procedure FormClose(A1: Integer; A2: Integer);  { draft }
    procedure PlayerComboBoxChange;  { draft }
    procedure DefendersCBChange;  { draft }
  end;

  { TCityEditor (instance size 8, VMT 00418DE0) }
  TCityEditor = class(TAoWMapObjectEditor)
  public
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu); override;
  end;


implementation

class procedure TCityEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

class procedure TCityEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu);
begin end;

procedure TCityEditForm.FormCreate;
begin end;

procedure TCityEditForm.RaceCBChange;
begin end;

procedure TCityEditForm.RazedBoxClick;
begin end;

procedure TCityEditForm.OKBtnClick(A1: Integer);
begin end;

procedure TCityEditForm.FormClose(A1: Integer; A2: Integer);
begin end;

procedure TCityEditForm.PlayerComboBoxChange;
begin end;

procedure TCityEditForm.DefendersCBChange;
begin end;


end.
