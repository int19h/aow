unit RBridge;

{ Draft declarations of RBridge, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, RMapObj;

type
  TBridgeResourceEditForm = class;
  TBridgeResourceEditor = class;


  { TBridgeResourceEditForm (instance size 804, VMT 00407494) }
  TBridgeResourceEditForm = class(TMapObjectResourceEditForm)
  public
  end;

  { TBridgeResourceEditor (instance size 8, VMT 004075B8) }
  TBridgeResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

class function TBridgeResourceEditor.EditorClassID: Integer;
begin Result := 0; end;

class procedure TBridgeResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;


end.
