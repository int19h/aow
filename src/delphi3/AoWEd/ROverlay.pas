unit ROverlay;

{ Draft declarations of ROverlay, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, RILTer, SpinEdit;

type
  TOverlayObjectResourceEditForm = class;
  TOverlayObjectResourceEditor = class;


  { TOverlayObjectResourceEditForm (instance size 840, VMT 004094DC) }
  TOverlayObjectResourceEditForm = class(TILTerrainResourceEditForm)
  public
    published
    CombatTerrainTagPanel: TPanel; { +033C }
    CTTLabel: TLabel; { +0340 }
    CombatTerrainTagEdit: TSpin; { +0344 }
    public
    constructor CreateForm(AEngine: THSEngine; Resource: TMapObjectResource; Done: TEditDoneEvent); override;
    procedure CombatTerrainTagEditChange;  { draft }
  end;

  { TOverlayObjectResourceEditor (instance size 8, VMT 00409694) }
  TOverlayObjectResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

uses OverlayObject;

class function TOverlayObjectResourceEditor.EditorClassID: Integer;
begin Result := $2009D; end;

class procedure TOverlayObjectResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin TOverlayObjectResourceEditForm.CreateForm(THSEngine(AEngine), TMapObjectResource(Obj), Done); end;

constructor TOverlayObjectResourceEditForm.CreateForm(AEngine: THSEngine; Resource: TMapObjectResource; Done: TEditDoneEvent);
begin
  inherited CreateForm(AEngine, Resource, Done);
  CombatTerrainTagEdit.Value := TOverlayObjectResource(FResource).FOverlayType;
end;

procedure TOverlayObjectResourceEditForm.CombatTerrainTagEditChange;
begin
  TOverlayObjectResource(FResource).FOverlayType := CombatTerrainTagEdit.Value;
end;


end.
