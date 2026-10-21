unit RPlayerStructure;

{ Draft declarations of RPlayerStructure, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, RConstr;

type
  TPlayerStructureResourceEditForm = class;
  TPlayerStructureResourceEditor = class;


  { TPlayerStructureResourceEditForm (instance size 888, VMT 0040982C) }
  TPlayerStructureResourceEditForm = class(TConstructionResourceEditForm)
  public
  end;

  { TPlayerStructureResourceEditor (instance size 8, VMT 00409974) }
  TPlayerStructureResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

class function TPlayerStructureResourceEditor.EditorClassID: Integer;
begin Result := 0; end;

class procedure TPlayerStructureResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;


end.
