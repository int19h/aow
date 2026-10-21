unit FleeLoc;

{ Draft declarations of FleeLoc, from AoWTCPCK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TFleeLocation = class;
  TFleeLocationResource = class;
  TMovementHS = class;


  { TFleeLocation (instance size 28, VMT 00430EB4) }
  TFleeLocation = class(TMapObject)
  public
    F_FleeLocation_10: Byte;
    F_FleeLocation_11: array[0..2] of Byte;
    F_FleeLocation_14: Integer;
    F_FleeLocation_18: Integer;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult); override;
    procedure Activate; override;
    procedure Deactivate; override;
    function CanSelect(Xhp, Yhp: Integer): Boolean; override;
    function GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList; override;
    function CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    function PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    procedure NewFrame(A1: Integer);  { draft }
  end;

  { TFleeLocationResource (instance size 52, VMT 00431048) }
  TFleeLocationResource = class(TMapObjectResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TMovementHS (instance size 16, VMT 00431140) }
  TMovementHS = class(TSingleHS)
  public
    F_MovementHS_0C: Byte;
    F_MovementHS_0D: array[0..2] of Byte;
    class function ClassID: Integer; override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult); override;
  end;

procedure RegisterFleeLocation(A1: Integer);  { draft }

implementation

procedure TFleeLocation.Deactivate;
begin end;

constructor TFleeLocation.Create(AOwner: Engine.TECustomNode);
begin end;

class function TFleeLocation.ClassID: Integer;
begin Result := 0; end;

function TFleeLocation.GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList;
begin FillChar(Result, SizeOf(Result), 0); end;

function TFleeLocation.GetShowPriority: Integer;
begin Result := 0; end;

function TFleeLocation.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin Result := False; end;

function TFleeLocation.CanSelect(Xhp, Yhp: Integer): Boolean;
begin Result := False; end;

function TFleeLocation.PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin Result := False; end;

procedure TFleeLocation.Activate;
begin end;

procedure TFleeLocation.CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult);
begin end;

procedure TFleeLocation.NewFrame(A1: Integer);
begin end;

procedure TFleeLocation.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

class function TFleeLocationResource.ClassID: Integer;
begin Result := 0; end;

class function TFleeLocationResource.ResourceEditName: string;
begin Result := ''; end;

function TFleeLocationResource.ResourceUserClassID: Integer;
begin Result := 0; end;

class function TMovementHS.ClassID: Integer;
begin Result := 0; end;

function TMovementHS.GetShowPriority: Integer;
begin Result := 0; end;

procedure TMovementHS.CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult);
begin end;

procedure TMovementHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure RegisterFleeLocation(A1: Integer);
begin end;


initialization
finalization

end.
