unit RCTerrain;

{ Draft declarations of RCTerrain, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, RTerrain, SpinEdit;

type
  TCombatTerrainResourceEditForm = class;
  TCombatTerrainResourceEditor = class;


  { TCombatTerrainResourceEditForm (instance size 876, VMT 0040AD98) }
  TCombatTerrainResourceEditForm = class(TTerrainResourceEditForm)
  public
    published
    CombatSettings: TTabSheet; { +0348 }
    CPanel: TPanel; { +034C }
    DefenseValue: TLabel; { +0350 }
    BurnValue: TLabel; { +0354 }
    DefenseValueEdit: TSpin; { +0358 }
    BurnValueEdit: TSpin; { +035C }
    Label11: TLabel; { +0360 }
    HitPointsEdit: TSpin; { +0364 }
    MeleeTargetEdit: TCheckBox; { +0368 }
    public
    procedure FormCreate;  { draft }
  end;

  { TCombatTerrainResourceEditor (instance size 8, VMT 0040AFC0) }
  TCombatTerrainResourceEditor = class(TEObjectEditor)
  public
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

class procedure TCombatTerrainResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

procedure TCombatTerrainResourceEditForm.FormCreate;
begin end;


end.
