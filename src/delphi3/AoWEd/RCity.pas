unit RCity;

{ Draft declarations of RCity, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, RPlayerStructure;

type
  TCityResourceEditForm = class;
  TCityResourceEditor = class;


  { TCityResourceEditForm (instance size 888, VMT 00409A9C) }
  TCityResourceEditForm = class(TPlayerStructureResourceEditForm)
  public
    procedure vmt90(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    function vmt94(A1: Byte; A2: Integer; A3: Integer; A4: Integer; A5: Integer): Integer; override;
    procedure ComplexBoxClick;  { draft }
  end;

  { TCityResourceEditor (instance size 8, VMT 00409BDC) }
  TCityResourceEditor = class(TEObjectEditor)
  public
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

class procedure TCityResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

function TCityResourceEditForm.vmt94(A1: Byte; A2: Integer; A3: Integer; A4: Integer; A5: Integer): Integer;
begin Result := 0; end;

procedure TCityResourceEditForm.vmt90(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TCityResourceEditForm.ComplexBoxClick;
begin end;


end.
