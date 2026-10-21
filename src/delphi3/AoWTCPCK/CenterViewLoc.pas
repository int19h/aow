unit CenterViewLoc;

{ Draft declarations of CenterViewLoc, from AoWTCPCK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TCenterViewLocation = class;
  TCenterViewLocationResource = class;


  { TCenterViewLocation (instance size 16, VMT 004356E0) }
  TCenterViewLocation = class(TMapObject)
  public
    class function ClassID: Integer; override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure Activate; override;
    procedure Deactivate; override;
    function CanSelect(Xhp, Yhp: Integer): Boolean; override;
    function GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList; override;
    function CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    function PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
  end;

  { TCenterViewLocationResource (instance size 52, VMT 00435884) }
  TCenterViewLocationResource = class(TMapObjectResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
    procedure SetLevel(Value: Byte); override;
  end;

procedure RegisterCenterViewLocation(A1: Integer);  { draft }

implementation

class function TCenterViewLocation.ClassID: Integer;
begin Result := 0; end;

function TCenterViewLocation.GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList;
begin FillChar(Result, SizeOf(Result), 0); end;

function TCenterViewLocation.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin Result := False; end;

function TCenterViewLocation.CanSelect(Xhp, Yhp: Integer): Boolean;
begin Result := False; end;

function TCenterViewLocation.PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin Result := False; end;

procedure TCenterViewLocation.Activate;
begin end;

procedure TCenterViewLocation.Deactivate;
begin end;

procedure TCenterViewLocation.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

constructor TCenterViewLocationResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TCenterViewLocationResource.ClassID: Integer;
begin Result := 0; end;

procedure TCenterViewLocationResource.SetLevel(Value: Byte);
begin end;

class function TCenterViewLocationResource.ResourceEditName: string;
begin Result := ''; end;

function TCenterViewLocationResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterCenterViewLocation(A1: Integer);
begin end;


initialization
finalization

end.
