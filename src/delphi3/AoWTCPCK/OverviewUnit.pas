unit OverviewUnit;

{ Draft declarations of OverviewUnit, from AoWTCPCK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TOverviewUnitHS = class;


  { TOverviewUnitHS (instance size 32, VMT 0043765C) }
  TOverviewUnitHS = class(TUnitHS)
  public
    F_OverviewUnitHS_1C: Integer;
    destructor Destroy; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure ShowShadow(X, Y: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure SetU(A1: Integer);  { draft }
  end;

procedure PlaceOverviewUnit(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }

implementation

destructor TOverviewUnitHS.Destroy;
begin end;

procedure TOverviewUnitHS.SetU(A1: Integer);
begin end;

procedure TOverviewUnitHS.ShowShadow(X, Y: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TOverviewUnitHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure PlaceOverviewUnit(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;


initialization
finalization

end.
