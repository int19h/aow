unit RRoad;

{ Draft declarations of RRoad, from AoWEd.exe.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, RMapObj;

type
  TRoadResourceEditForm = class;
  TRoadResourceEditor = class;


  { TRoadResourceEditForm (instance size 804, VMT 00407D74) }
  TRoadResourceEditForm = class(TMapObjectResourceEditForm)
  public
  end;

  { TRoadResourceEditor (instance size 8, VMT 00407E94) }
  TRoadResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

class function TRoadResourceEditor.EditorClassID: Integer;
begin
  Result := $20165;
end;

class procedure TRoadResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin
  TRoadResourceEditForm.CreateForm(THSEngine(AEngine), TMapObjectResource(Obj), Done);
end;


end.
