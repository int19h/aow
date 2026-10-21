unit RAoWTer;

{ Draft declarations of RAoWTer, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Terrain response tag uses the inherited $308 resource. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, RTerrain;

type
  TAoWTerrainResourceEditForm = class;
  TAoWTerrainResourceEditor = class;


  { TAoWTerrainResourceEditForm (instance size 852, VMT 0040822C) }
  TAoWTerrainResourceEditForm = class(TTerrainResourceEditForm)
  public
    published
    CombatTerrainTagPanel: TPanel; { +0348 }
    Label11: TLabel; { +034C }
    CombatTerrainTagBox: TComboBox; { +0350 }
    public
    procedure FormCreate(Sender: TObject);
    procedure CombatTerrainTagBoxChange(Sender: TObject);
  end;

  { TAoWTerrainResourceEditor (instance size 8, VMT 004083EC) }
  TAoWTerrainResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

uses AoWTer;

class function TAoWTerrainResourceEditor.EditorClassID: Integer;
begin
  Result := $20167;
end;

class procedure TAoWTerrainResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin
  TAoWTerrainResourceEditForm.CreateForm(THSEngine(AEngine), TMapObjectResource(Obj), Done);
end;

procedure TAoWTerrainResourceEditForm.FormCreate(Sender: TObject);
begin
  inherited FormCreate(Sender);
  CombatTerrainTagPanel.Visible := FResource is TAoWTerrainResource;
  if CombatTerrainTagPanel.Visible then
    CombatTerrainTagBox.ItemIndex := TAoWTerrainResource(FResource).FMapFieldResponse;
end;

procedure TAoWTerrainResourceEditForm.CombatTerrainTagBoxChange(Sender: TObject);
begin
  TAoWTerrainResource(FResource).FMapFieldResponse := CombatTerrainTagBox.ItemIndex;
end;

end.
