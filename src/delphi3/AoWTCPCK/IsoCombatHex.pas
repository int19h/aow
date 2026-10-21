unit IsoCombatHex;

{ Isometric combat hexagons, recovered from AoWTCPCK.dpl. }

{$O-,R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TIsometricCombatHexagon = class;
  TIsometricCombatHexagonResource = class;


  { TIsometricCombatHexagon (instance size 24, VMT 0043386C) }
  TIsometricCombatHexagon = class(TUpperIsometricHexagon)
  public
    class function ClassID: Integer; override;
    function GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList; override;
    procedure ShowDynamic(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
  end;

  { TIsometricCombatHexagonResource (instance size 56, VMT 00433A24) }
  TIsometricCombatHexagonResource = class(TUpperIsometricHexagonResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
    function GetHexagonControl: HSEngine.THexagonControl; override;
  end;

procedure RegisterIsometricCombatHexagon(AEngine: TEngine);

implementation

uses AoWE;

class function TIsometricCombatHexagon.ClassID: Integer;
begin Result := $22050A; end;

function TIsometricCombatHexagon.GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList;
begin Result := AoWHSSet.FCombatResources; end;

procedure TIsometricCombatHexagon.ShowDynamic(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  IL: TCustomImageLibrary;
  Xhp, Yhp: Integer;
  Variant: Integer;
begin
  HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhp, Yhp);
  Xhp := Xhp - XhpSurf - 8;
  Yhp := Yhp - YhpSurf;
  IL := FResource.ImageSequenceList.ImageSequences[0].ImageLibrary;
  Variant := (Integer(Self) shr 8) and 3;
  if Variant = 3 then Variant := 0;
  IL[FSides shr 6 + 40].Show(Xhp, Yhp, SurfaceDesc);
  if FOpenSides <> 0 then
  begin
    Dec(Yhp, 38);
    if FOpenSides and 1 <> 0 then
    begin
      if FOpenSides and $20 = 0 then IL[18].Show(Xhp - 19, Yhp - 48 - 16, SurfaceDesc);
      if FOpenSides and 2 = 0 then IL[19].Show(Xhp - 19, Yhp - 48 - 16, SurfaceDesc);
      if FOpenSides and $22 = $22 then
        IL[23].Show(Xhp - 20, Yhp - 48 - 16, SurfaceDesc)
      else if FOpenSides and $22 = 0 then
        IL[20].Show(Xhp - 20, Yhp - 50 - 16, SurfaceDesc);
    end;
    if FOpenSides and 8 <> 0 then
    begin
      if FOpenSides and $10 <> 0 then
        if FOpenSides and $20 <> 0 then
          IL[17].Show(Xhp - 19 - 32, Yhp - 16, SurfaceDesc)
        else
          IL[Variant + 3].Show(Xhp - 19 - 32, Yhp - 16, SurfaceDesc);
      if FOpenSides and 4 <> 0 then
        if FOpenSides and 2 <> 0 then
          IL[16].Show(Xhp - 19 + 16 + 16, Yhp - 16, SurfaceDesc)
        else
          IL[Variant + 0].Show(Xhp - 19 + 16 + 16, Yhp - 16, SurfaceDesc);
      if FOpenSides and $14 = $14 then
        IL[13].Show(Xhp - 19, Yhp, SurfaceDesc)
      else if FOpenSides and $14 = 0 then
        IL[6].Show(Xhp - 19, Yhp, SurfaceDesc);
    end
    else
    begin
      if FOpenSides and $10 <> 0 then
        if FOpenSides and $20 = 0 then
          IL[25].Show(Xhp - 19 - 32, Yhp - 16, SurfaceDesc)
        else if FOpenSides and 1 <> 0 then
          IL[15].Show(Xhp - 19 - 32, Yhp - 16, SurfaceDesc)
        else
          IL[Variant + 10].Show(Xhp - 19 - 32, Yhp - 16, SurfaceDesc);
      if FOpenSides and 4 <> 0 then
        if FOpenSides and 2 = 0 then
          IL[24].Show(Xhp - 19 + 32, Yhp - 16, SurfaceDesc)
        else if FOpenSides and 1 <> 0 then
          IL[14].Show(Xhp - 19 + 32, Yhp - 16, SurfaceDesc)
        else
          IL[Variant + 7].Show(Xhp - 19 + 32, Yhp - 16, SurfaceDesc);
    end;
  end;
end;

class function TIsometricCombatHexagonResource.ClassID: Integer;
begin Result := $22050B; end;

class function TIsometricCombatHexagonResource.ResourceEditName: string;
begin Result := 'Combat ISO-Hex'; end;

function TIsometricCombatHexagonResource.ResourceUserClassID: Integer;
begin Result := $22050A; end;

function TIsometricCombatHexagonResource.GetHexagonControl: HSEngine.THexagonControl;
begin Result := TAoWHSSet(Engine.HSSet).FCombatHexagons; end;

procedure RegisterIsometricCombatHexagon(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TIsometricCombatHexagonResource, TIsometricCombatHexagon]);
end;

initialization
finalization

end.
