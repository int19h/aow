unit CenterViewLoc;

{ CenterViewLoc, AoWTCPCK.dpl. Original layouts and VMT order.
  TCenterViewLocation: size $10, no added fields. Resource: size $34, no added fields. }

{$O-,Q+,R+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWTC;

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

procedure RegisterCenterViewLocation(AEngine: TEngine);

implementation

class function TCenterViewLocation.ClassID: Integer;
begin Result := $221528; end;

function TCenterViewLocation.GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList;
begin Result := AoWHSSet.FCombatResources; end;

function TCenterViewLocation.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin Result := True; end;

function TCenterViewLocation.CanSelect(Xhp, Yhp: Integer): Boolean;
begin Result := True; end;

function TCenterViewLocation.PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin
  Result := inherited PlaceHX(MapContainer, Xhx, Yhx, Lhx);
end;

procedure TCenterViewLocation.Activate;
begin
  inherited Activate;
  if not GetEditMode then
  begin
    if AoWCombatMap.FCenterViewLocation <> nil then AoWCombatMap.FCenterViewLocation.Free;
    AoWCombatMap.FCenterViewLocation := Self;
  end;
end;

procedure TCenterViewLocation.Deactivate;
begin
  inherited Deactivate;
  if not GetEditMode then
    if AoWCombatMap.FCenterViewLocation = Self then AoWCombatMap.FCenterViewLocation := nil;
end;

procedure TCenterViewLocation.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin
  if msEditting in AoWCombatMap.Status then inherited Show(XhpSurf, YhpSurf, SurfaceDesc);
end;

constructor TCenterViewLocationResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  SetLevel(27);
end;

class function TCenterViewLocationResource.ClassID: Integer;
begin Result := $221529; end;

procedure TCenterViewLocationResource.SetLevel(Value: Byte);
begin
  inherited SetLevel(27);
end;

class function TCenterViewLocationResource.ResourceEditName: string;
begin Result := 'Center View Location'; end;

function TCenterViewLocationResource.ResourceUserClassID: Integer;
begin Result := $221528; end;

procedure RegisterCenterViewLocation(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TCenterViewLocationResource, TCenterViewLocation]);
end;


initialization
finalization

end.
