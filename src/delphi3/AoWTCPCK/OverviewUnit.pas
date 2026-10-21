unit OverviewUnit;

{ OverviewUnit of AoWTCPCK.dpl: reference-counted unit previews on the combat map.
  All five routines match the original Delphi 3 code. }

{$O-,R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWTC;

type
  TOverviewUnitHS = class;


  { TOverviewUnitHS (instance size 32, VMT 0043765C): $1C FUnit. }
  TOverviewUnitHS = class(TUnitHS)
  public
    FUnit: TAbstractUnit; { $1C }
    destructor Destroy; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure ShowShadow(X, Y: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure SetU(U: TAbstractUnit);
  end;

procedure PlaceOverviewUnit(Map: TAoWCombatMap; U: TAbstractUnit; Position, Index: Integer);

implementation

destructor TOverviewUnitHS.Destroy;
begin
  SetU(nil);
  inherited Destroy;
end;

procedure TOverviewUnitHS.SetU(U: TAbstractUnit);
begin
  if FUnit <> nil then FUnit.Release;
  FUnit := U;
  if FUnit <> nil then begin
    FUnit.AddRef;
    SetUnitGFXResourceIndex(FUnit.GetUnitGFXResourceIndex);
  end;
end;

procedure TOverviewUnitHS.ShowShadow(X, Y: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin
  inherited ShowShadow(X, Y, SurfaceDesc);
end;

procedure TOverviewUnitHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin
  inherited Show(XhpSurf, YhpSurf, SurfaceDesc);
end;

procedure PlaceOverviewUnit(Map: TAoWCombatMap; U: TAbstractUnit; Position, Index: Integer);
var
  HS: TOverviewUnitHS;
  Overlay: Shortint;
  Occupant: TTacticalCombatUnitHS;
  X0, Y0, X, Y, I: Integer;
  P: TXYL;
begin
  HS := TOverviewUnitHS.Create(nil);
  HS.SetU(U);
  P := Map.FUnitPositions.GetUnitPosition(Position, Index);
  X0 := P.X;
  Y0 := P.Y;
  I := 0;
  repeat
    CenterHNtoHX(X0, Y0, I, X, Y);
    Overlay := AoWCombatMap.MapContainer.MapLevels[0].Field[X, Y].OverlayType;
    Occupant := TTacticalCombatUnitHS(AoWCombatMap.MapContainer.MapLevels[0].Field[X, Y].FindOwnedChild($220104));
    Inc(I);
  until (Overlay <> 8) and (Occupant = nil);
  if not Map.PlaceHX(HS, X, Y, 0) then HS.Free;
end;


initialization
finalization

end.
