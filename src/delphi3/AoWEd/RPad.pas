unit RPad;

{ Draft declarations of RPad, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, RILTer;

type
  TPadEditForm = class;
  TPadResourceEditor = class;


  { TPadEditForm (instance size 828, VMT 00407264) }
  TPadEditForm = class(TILTerrainResourceEditForm)
  public
  end;

  { TPadResourceEditor (instance size 8, VMT 00407378) }
  TPadResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

class function TPadResourceEditor.EditorClassID: Integer;
begin Result := 0; end;

class procedure TPadResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;


end.
