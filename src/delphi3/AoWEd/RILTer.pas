unit RILTer;

{ Draft declarations of RILTer, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, RMultiHx;

type
  TILTerrainResourceEditForm = class;
  TILTerrainResourceEditor = class;


  { TILTerrainResourceEditForm (instance size 828, VMT 00406D84) }
  TILTerrainResourceEditForm = class(TMultiHexResourceEditForm)
  public
    procedure vmt84; override;
    constructor CreateForm(AEngine: THSEngine; Resource: TMapObjectResource; Done: TEditDoneEvent); override;
    procedure vmt98(const SD: TSurfaceDesc); override;
    function vmt9C(A1: Integer): Boolean; override;
  end;

  { TILTerrainResourceEditor (instance size 8, VMT 00406EB4) }
  TILTerrainResourceEditor = class(TEObjectEditor)
  public
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

class procedure TILTerrainResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

constructor TILTerrainResourceEditForm.CreateForm(AEngine: THSEngine; Resource: TMapObjectResource; Done: TEditDoneEvent);
begin end;

procedure TILTerrainResourceEditForm.vmt84;
begin end;

procedure TILTerrainResourceEditForm.vmt98(const SD: TSurfaceDesc);
begin end;

function TILTerrainResourceEditForm.vmt9C(A1: Integer): Boolean;
begin Result := False; end;


end.
