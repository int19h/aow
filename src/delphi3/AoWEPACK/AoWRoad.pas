unit AoWRoad;

{ Draft declarations of AoWRoad, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TAoWRoad = class;


  { TAoWRoad (instance size 20, VMT 5579B6FC) }
  TAoWRoad = class(TRoad)
  public
    procedure UpdateTransitions; override;
  end;

procedure RegisterAoWRoad;  { draft }

implementation

procedure TAoWRoad.UpdateTransitions;
begin end;

procedure RegisterAoWRoad;
begin end;


initialization
finalization

end.
