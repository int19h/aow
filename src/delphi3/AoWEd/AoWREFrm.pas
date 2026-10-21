unit AoWREFrm;

{ Draft declarations of AoWREFrm, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, ResEForm;

type
  TAoWResourceEditForm = class;


  { TAoWResourceEditForm (instance size 508, VMT 0040BC6C) }
  TAoWResourceEditForm = class(TResourceEditForm)
  public
    destructor Destroy; override;
    function vmt80(A1: Byte; A2: Integer; A3: Integer; A4: Integer; A5: Integer): Integer; override;
  end;


implementation

function TAoWResourceEditForm.vmt80(A1: Byte; A2: Integer; A3: Integer; A4: Integer; A5: Integer): Integer;
begin Result := 0; end;

destructor TAoWResourceEditForm.Destroy;
begin end;


end.
