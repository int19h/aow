unit BorderHx;

{ The BorderHx unit of HSEPack.dpl: the border hexagon (TBorderHexagon, ClassID $20557) drawn at
  level 11 over the map edge; it also adds itself to the hexagon above (HN 1) of its map field.
  TBorderHexagonResource has ClassID $20558. }

interface

uses
  Windows, SysUtils, Classes, Engine, GFXE, ImageLib, HSEngine;

type
  { BorderHx.TBorderHexagon (instance size 16) }
  TBorderHexagon = class(TAbstractBorderHexagon)
  public
    procedure SetOwner(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc); override;
    function CanSelect(Xhp, Yhp: Integer): Boolean; override;
    function GetLevel: Byte; override;
    function GetShowPriority: Integer; override;
    function CanChangeTerrain(const Info: THSSenderInfo): Boolean; override;
  end;

  { BorderHx.TBorderHexagonResource (instance size 52) }
  TBorderHexagonResource = class(TAbstractBorderHexagonResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterBorderHexagon(Engine: TEngine);

implementation {$IFDEF RUNTIME_PACKAGES} uses Road; {$ENDIF}

{ TBorderHexagon }

procedure TBorderHexagon.SetOwner(AOwner: TECustomNode);
var
  OldField: TECustomNode;
begin
  if AOwner <> Owner then
  begin
    OldField := Owner;
    if (OldField <> nil) and (OldField is TMapField) and (TMapField(OldField).Yhx <> 0) then
      TMapLevel(OldField.Owner).GetField(TMapField(OldField).Xhx,
        TMapField(Owner).Yhx - 1).RemoveChild(Self);
    inherited SetOwner(AOwner);
    AOwner := Owner;
    if (AOwner <> nil) and (AOwner is TMapField) and (TMapField(AOwner).Yhx <> 0) then
      TMapLevel(AOwner.Owner).GetField(TMapField(AOwner).Xhx,
        TMapField(Owner).Yhx - 1).AddHS(Self, 1);
  end
  else
    inherited SetOwner(AOwner);
end;

class function TBorderHexagon.ClassID: Integer;
begin
  Result := $20557;
end;

procedure TBorderHexagon.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  Xhp, Yhp: Integer;
begin
  HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhp, Yhp);
  FResource.ImageLibrary[0].Show(Xhp - XhpSurf - 8, Yhp - YhpSurf, SurfaceDesc);
end;

function TBorderHexagon.CanSelect(Xhp, Yhp: Integer): Boolean;
begin
  Result := False;
end;

function TBorderHexagon.GetLevel: Byte;
begin
  Result := 11;
end;

function TBorderHexagon.GetShowPriority: Integer;
var
  MapField: TMapField;
  Xhx: ShortInt;
  Xhp, Yhp: Integer;
begin
  MapField := TMapField(Owner);
  Xhx := MapField.Xhx;
  Xhp := Xhx * 32 + 8;
  Yhp := (Xhx and 1) * 16 + MapField.Yhx * 32;
  Result := (Yhp + 32) shl 13 + 11 shl 26 + (Xhp + 8);
end;

function TBorderHexagon.CanChangeTerrain(const Info: THSSenderInfo): Boolean;
begin
  Result := Info.HN <> 0;
end;

{ TBorderHexagonResource }

class function TBorderHexagonResource.ClassID: Integer;
begin
  Result := $20558;
end;

class function TBorderHexagonResource.ResourceEditName: string;
begin
  Result := 'Border Hexagon';
end;

function TBorderHexagonResource.ResourceUserClassID: Integer;
begin
  Result := $20557;
end;

procedure RegisterBorderHexagon(Engine: TEngine);
begin
  Engine.RegisterEClasses([TBorderHexagon, TBorderHexagonResource]);
end;

end.
