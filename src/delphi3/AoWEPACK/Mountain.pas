unit Mountain;

{ Draft declarations of Mountain, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWTer, GlobalTargetSpells;

type
  TMountainMO = class;
  TMountainMOR = class;
  TRaisedMountain = class;
  TRaisedMountainResource = class;
  TRaiseTerrainTE = class;
  TRaiseTerrain = class;


  { TMountainMO (instance size 20, VMT 557A266C) }
  TMountainMO = class(TAoWTerrain)
  public
    class function ClassID: Integer; override;
    function GetOverlay(Index: Integer): Shortint; override;
    function CanChangeTerrain(const Info: HSEngine.THSSenderInfo): Boolean; override;
    function CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    procedure ValidMountainOverlap(A1: Integer; A2: Integer);  { draft }
  end;

  { TMountainMOR (instance size 76, VMT 557A2814) }
  TMountainMOR = class(TAoWTerrainResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TRaisedMountain (instance size 32, VMT 557A2940) }
  TRaisedMountain = class(TILTerrainMO)
  public
    F_RaisedMountain_1C: array[0..0] of Byte;
    F_RaisedMountain_1D: Byte;
    F_RaisedMountain_1E: Byte;
    F_RaisedMountain_1F: Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure RestoreTerrain;  { draft }
    procedure NewTurn(A1: Byte);  { draft }
    procedure ShowRaiseTerrainAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure NewFrameRaiseTerrainAnimation(A1: Integer; A2: Integer);  { draft }
  end;

  { TRaisedMountainResource (instance size 68, VMT 557A2AF4) }
  TRaisedMountainResource = class(TILTerrainMOR)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TRaiseTerrainTE (instance size 36, VMT 557A2BF8) }
  TRaiseTerrainTE = class(TGlobalTargetSpellTE)
  public
    class function ClassID: Integer; override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure RaiseTerrain(A1: Integer);  { draft }
  end;

  { TRaiseTerrain (instance size 60, VMT 557A2CD0) }
  TRaiseTerrain = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: Integer; A2: Integer); override;
    procedure TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ValidTargetSelectionMapF(A1: Integer); override;
    procedure ValidTargetMapF(A1: Integer); override;
  end;

procedure RegisterMountain(A1: Integer);  { draft }
procedure UnRegisterMountain(A1: Integer);  { draft }

implementation

class function TMountainMO.ClassID: Integer;
begin Result := 0; end;

function TMountainMO.GetOverlay(Index: Integer): Shortint;
begin Result := 0; end;

function TMountainMO.CanChangeTerrain(const Info: HSEngine.THSSenderInfo): Boolean;
begin Result := False; end;

procedure TMountainMO.ValidMountainOverlap(A1: Integer; A2: Integer);
begin end;

function TMountainMO.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin Result := False; end;

class function TMountainMOR.ClassID: Integer;
begin Result := 0; end;

class function TMountainMOR.ResourceEditName: string;
begin Result := ''; end;

function TMountainMOR.ResourceUserClassID: Integer;
begin Result := 0; end;

class function TRaisedMountain.ClassID: Integer;
begin Result := 0; end;

procedure TRaisedMountain.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TRaisedMountain.RestoreTerrain;
begin end;

procedure TRaisedMountain.NewTurn(A1: Byte);
begin end;

procedure TRaisedMountain.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TRaisedMountain.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

procedure TRaisedMountain.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TRaisedMountain.ShowRaiseTerrainAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TRaisedMountain.NewFrameRaiseTerrainAnimation(A1: Integer; A2: Integer);
begin end;

class function TRaisedMountainResource.ClassID: Integer;
begin Result := 0; end;

class function TRaisedMountainResource.ResourceEditName: string;
begin Result := ''; end;

function TRaisedMountainResource.ResourceUserClassID: Integer;
begin Result := 0; end;

class function TRaiseTerrainTE.ClassID: Integer;
begin Result := 0; end;

procedure TRaiseTerrainTE.RaiseTerrain(A1: Integer);
begin end;

procedure TRaiseTerrainTE.Process(A1: Integer; A2: Integer);
begin end;

constructor TRaiseTerrain.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TRaiseTerrain.ValidTargetMapF(A1: Integer);
begin end;

procedure TRaiseTerrain.ValidTargetSelectionMapF(A1: Integer);
begin end;

procedure TRaiseTerrain.SetupTargetSelection(A1: Integer; A2: Integer);
begin end;

procedure TRaiseTerrain.TargetSelected(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure RegisterMountain(A1: Integer);
begin end;

procedure UnRegisterMountain(A1: Integer);
begin end;


initialization
finalization

end.
