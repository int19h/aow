unit RIsoHex;

{ Draft declarations of RIsoHex, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, RMapObj;

type
  TIsometricHexagonEditForm = class;
  TIsometricHexagonResourceEditor = class;


  { TIsometricHexagonEditForm (instance size 804, VMT 00407FB0) }
  TIsometricHexagonEditForm = class(TMapObjectResourceEditForm)
  public
    procedure FormCreate(Sender: TObject);
  end;

  { TIsometricHexagonResourceEditor (instance size 8, VMT 004080EC) }
  TIsometricHexagonResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

class function TIsometricHexagonResourceEditor.EditorClassID: Integer;
begin Result := 0; end;

class procedure TIsometricHexagonResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

procedure TIsometricHexagonEditForm.FormCreate(Sender: TObject);
begin
  inherited FormCreate(Sender);
  vmt84;
end;


end.
