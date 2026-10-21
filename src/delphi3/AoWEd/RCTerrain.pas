unit RCTerrain;

{ Draft declarations of RCTerrain, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, RTerrain, SpinEdit, CombatTerrain, AoWE;

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
    procedure FormCreate(Sender: TObject);
  end;

  { TCombatTerrainResourceEditor (instance size 8, VMT 0040AFC0) }
  TCombatTerrainResourceEditor = class(TEObjectEditor)
  public
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

class procedure TCombatTerrainResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

procedure TCombatTerrainResourceEditForm.FormCreate(Sender: TObject);
begin
  inherited FormCreate(Sender);
  DefenseValueEdit.Value := TCombatTerrainResource(FResource).FDefense;
  BurnValueEdit.Value := TCombatTerrainResource(FResource).FBurnValue;
  HitPointsEdit.Value := TCombatTerrainResource(FResource).FHitPoints;
  MeleeTargetEdit.Checked := TCombatTerrainResource(FResource).FMeleeTarget;
  with DecorationComboBox.Items do
  begin
    Clear;
    Add(TranslateRStr(NoneRStr));
    Add(TranslateRStr(PineRStr));
    Add(TranslateRStr(OakRStr));
    Add(TranslateRStr(WillowRStr));
    Add(TranslateRStr(FlowerRStr));
    Add(TranslateRStr(ToadRStr));
    Add(TranslateRStr(DeadPineRStr));
    Add(TranslateRStr(DeadOakRStr));
    Add(TranslateRStr(DeadTrunkRStr));
    Add(TranslateRStr(CropRStr));
    Add('Brush');
    Add('Rock');
    Add('Bones');
    Add('Hill');
    Add('MedRockStr');
    Add('Big Bones');
    Add('Big Rock');
    Add('Earth');
    Add('Crack');
    Add('19');
    Add('20');
    Add('21');
    Add('22');
    Add('23');
    Add('24');
    Add('25');
  end;
  DecorationComboBox.ItemIndex := TCombatTerrainResource(FResource).DecorationType;
end;


end.
