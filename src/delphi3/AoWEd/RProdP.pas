unit RProdP;

{ Draft declarations of RProdP, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, RPlayerStructure, UnitIGrd;

type
  TProdPlaceResEditForm = class;
  TProductionPlaceResourceEditor = class;


  { TProdPlaceResEditForm (instance size 908, VMT 00409DB4) }
  TProdPlaceResEditForm = class(TPlayerStructureResourceEditForm)
  public
    published
    ProductionSheet: TTabSheet; { +0378 }
    GroupBox4: TGroupBox; { +037C }
    ProductionGrid: TUnitIndexGrid; { +0380 }
    AddBtn: TButton; { +0384 }
    DeleteBtn: TButton; { +0388 }
    public
    procedure FormCreate;  { draft }
    procedure FormDestroy;  { draft }
    procedure AddBtnClick;  { draft }
    procedure DeleteBtnClick;  { draft }
    procedure MainPageControlChange;  { draft }
    procedure CloseBtnClick(A1: Integer);  { draft }
  end;

  { TProductionPlaceResourceEditor (instance size 8, VMT 00409FC8) }
  TProductionPlaceResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

class function TProductionPlaceResourceEditor.EditorClassID: Integer;
begin Result := 0; end;

class procedure TProductionPlaceResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

procedure TProdPlaceResEditForm.FormCreate;
begin end;

procedure TProdPlaceResEditForm.FormDestroy;
begin end;

procedure TProdPlaceResEditForm.AddBtnClick;
begin end;

procedure TProdPlaceResEditForm.DeleteBtnClick;
begin end;

procedure TProdPlaceResEditForm.MainPageControlChange;
begin end;

procedure TProdPlaceResEditForm.CloseBtnClick(A1: Integer);
begin end;


end.
