unit AoWHex;

{ Draft declarations of AoWHex, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TAoWHexagon = class;
  TAoWHexagonResource = class;
  TAoWBorderHexagon = class;
  TAoWWaterHexagon = class;
  TAoWWaterHexagonResource = class;


  { TAoWHexagon (instance size 20, VMT 5579A1D0) }
  TAoWHexagon = class(THexagon)
  public
    procedure ChangeTerrain(const Msg: HSEngine.THSTerrainInfo); override;
    procedure TerrainChanged(const Msg: HSEngine.THSTerrainInfo); override;
    procedure NeighbourTerrainChanged(HN: Integer; const Info: HSEngine.THSTerrainInfo); override;
    procedure UpdateTransition(Side: Byte); override;
  end;

  { TAoWHexagonResource (instance size 56, VMT 5579A364) }
  TAoWHexagonResource = class(THexagonResource)
  public
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
  end;

  { TAoWBorderHexagon (instance size 16, VMT 5579A458) }
  TAoWBorderHexagon = class(TBorderHexagon)
  public
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
  end;

  { TAoWWaterHexagon (instance size 32, VMT 5579A5F8) }
  TAoWWaterHexagon = class(TLowerIsometricHexagon)
  public
    F_AoWWaterHexagon_18: Byte;
    F_AoWWaterHexagon_19: Byte;
    F_AoWWaterHexagon_1A: Byte;
    F_AoWWaterHexagon_1B: Byte;
    F_AoWWaterHexagon_1C: Byte;
    F_AoWWaterHexagon_1D: Byte;
    F_AoWWaterHexagon_1E: Byte;
    F_AoWWaterHexagon_1F: Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure UpdateTransitions; override;
    procedure ShowDynamic(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
  end;

  { TAoWWaterHexagonResource (instance size 56, VMT 5579A7A0) }
  TAoWWaterHexagonResource = class(TLowerIsometricHexagonResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterAoWHexagon(A1: Integer);  { draft }

implementation

procedure TAoWHexagon.NeighbourTerrainChanged(HN: Integer; const Info: HSEngine.THSTerrainInfo);
begin end;

procedure TAoWHexagon.ChangeTerrain(const Msg: HSEngine.THSTerrainInfo);
begin end;

procedure TAoWHexagon.TerrainChanged(const Msg: HSEngine.THSTerrainInfo);
begin end;

procedure TAoWHexagon.UpdateTransition(Side: Byte);
begin end;

procedure TAoWHexagonResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TAoWBorderHexagon.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin end;

constructor TAoWWaterHexagon.Create(AOwner: Engine.TECustomNode);
begin end;

class function TAoWWaterHexagon.ClassID: Integer;
begin Result := 0; end;

procedure TAoWWaterHexagon.UpdateTransitions;
begin end;

procedure TAoWWaterHexagon.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TAoWWaterHexagon.ShowDynamic(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

constructor TAoWWaterHexagonResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TAoWWaterHexagonResource.ClassID: Integer;
begin Result := 0; end;

class function TAoWWaterHexagonResource.ResourceEditName: string;
begin Result := ''; end;

function TAoWWaterHexagonResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterAoWHexagon(A1: Integer);
begin end;


initialization
finalization

end.
