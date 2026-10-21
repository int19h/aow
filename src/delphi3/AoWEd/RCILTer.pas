unit RCILTer;

{ Draft declarations of RCILTer, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, RILTer, SpinEdit;

type
  TCombatILTerrainResourceEditForm = class;
  TCombatILTerrainResourceEditor = class;


  { TCombatILTerrainResourceEditForm (instance size 864, VMT 0040B534) }
  TCombatILTerrainResourceEditForm = class(TILTerrainResourceEditForm)
  public
    published
    CombatSettings: TTabSheet; { +033C }
    CPanel: TPanel; { +0340 }
    DefenseValue: TLabel; { +0344 }
    BurnValue: TLabel; { +0348 }
    DefenseValueEdit: TSpin; { +034C }
    BurnValueEdit: TSpin; { +0350 }
    CityWallPanel: TPanel; { +0354 }
    Label10: TLabel; { +0358 }
    CityWallDirectionEdit: TSpin; { +035C }
    public
    procedure FormCreate;  { draft }
    procedure CloseBtnClick(A1: Integer);  { draft }
    procedure CityWallDirectionEditUpdate;  { draft }
  end;

  { TCombatILTerrainResourceEditor (instance size 8, VMT 0040B780) }
  TCombatILTerrainResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

class function TCombatILTerrainResourceEditor.EditorClassID: Integer;
begin Result := 0; end;

class procedure TCombatILTerrainResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

procedure TCombatILTerrainResourceEditForm.FormCreate;
begin end;

procedure TCombatILTerrainResourceEditForm.CloseBtnClick(A1: Integer);
begin end;

procedure TCombatILTerrainResourceEditForm.CityWallDirectionEditUpdate;
begin end;


end.
